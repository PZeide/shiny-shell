#include "provider.hpp"

#include "dbus_client.h"
#include "dbus_location.h"
#include "dbus_manager.h"
#include "location.hpp"
#include <qcontainerfwd.h>
#include <qdatetime.h>
#include <qdbusconnection.h>
#include <qdbusextratypes.h>
#include <qdbusmessage.h>
#include <qdbusmetatype.h>
#include <qdbuspendingcall.h>
#include <qdbuspendingreply.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <qjsonparseerror.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qnetworkaccessmanager.h>
#include <qnetworkreply.h>
#include <qnetworkrequest.h>
#include <qnumeric.h>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qtimezone.h>
#include <qtmetamacros.h>
#include <qurl.h>
#include <qurlquery.h>

namespace Shiny::Location {

Q_LOGGING_CATEGORY(logLocation, "shiny.location", QtInfoMsg)

LocationProvider* LocationProvider::instance() {
    static LocationProvider* instance = new LocationProvider();
    return instance;
}

bool LocationProvider::active() const { return m_client && m_client->active(); }

Location* LocationProvider::location() const { return m_current; }

void LocationProvider::start() {
    if (!m_client) {
        // setup will call start when ready
        setupClient();
        return;
    }

    auto reply = m_client->Start();
    auto watcher = new QDBusPendingCallWatcher(reply, this);
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [watcher]() {
        QDBusPendingReply<> result = *watcher;
        if (!result.isError()) {
            qCDebug(logLocation) << "Client started successfully.";
        } else {
            qCWarning(logLocation) << "Failed to start client:" << result.error().message();
        }

        watcher->deleteLater();
    });
}

void LocationProvider::stop() {
    if (!m_client) {
        return;
    }

    auto reply = m_client->Stop();
    auto watcher = new QDBusPendingCallWatcher(reply, this);
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [watcher]() {
        QDBusPendingReply<> result = *watcher;
        if (!result.isError()) {
            qCDebug(logLocation) << "Client stopped successfully.";
        } else {
            qCWarning(logLocation) << "Failed to stop client:" << result.error().message();
        }

        watcher->deleteLater();
    });
}

void LocationProvider::refresh() {
    if (!m_client) {
        qCWarning(logLocation) << "Cannot refresh location, client is not started";
        return;
    }

    locationUpdated(m_client->location());
}

void LocationProvider::propertiesChanged(QString, QVariantMap changedProperties) {
    if (changedProperties.contains("Active")) {
        emit activeChanged();
    }
}

void LocationProvider::locationUpdated(const QDBusObjectPath& location) {
    qCDebug(logLocation) << "Updating location:" << location.path();

    if (location.path().isEmpty() || location.path() == "/") {
        qCWarning(logLocation) << "Cannot update the location because path is empty.";
        return;
    }

    auto bus = QDBusConnection::systemBus();
    DBusGeoClue2Location locationIface("org.freedesktop.GeoClue2", location.path(), bus, this);
    if (!locationIface.isValid()) {
        qCWarning(logLocation) << "Invalid location interface.";
        return;
    }

    double latitude = locationIface.latitude();
    double longitude = locationIface.longitude();

    if (m_current && qFuzzyCompare(m_current->latitude(), latitude) &&
        qFuzzyCompare(m_current->longitude(), longitude)) {
        qCDebug(logLocation) << "Same location, no need to reverse geocode";
        return;
    }

    QUrl url("https://nominatim.openstreetmap.org/reverse");
    QUrlQuery query;
    query.addQueryItem("lat", QString::number(latitude));
    query.addQueryItem("lon", QString::number(longitude));
    query.addQueryItem("zoom", "10");
    query.addQueryItem("format", "jsonv2");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "ShinyShell/1.0");

    QNetworkReply* reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this,
            [this, reply, latitude, longitude]() { handleReverseGeocodingReply(reply, latitude, longitude); });
}

void LocationProvider::handleReverseGeocodingReply(QNetworkReply* reply, double latitude, double longitude) {
    if (reply->error() != QNetworkReply::NoError) {
        qCWarning(logLocation) << "Cannot reverse geocode location:" << reply->errorString();
        return;
    }

    QJsonParseError err;
    QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "Invalid JSON:" << err.errorString();
        return;
    }

    QJsonObject root = document.object();
    QJsonObject address = root.value("address").toObject();
    QString city = root.value("name").toString();
    QString country = address.value("country").toString();
    QString countryCode = address.value("country_code").toString();
    QString region = "";

    if (!address.value("county").isUndefined()) {
        region = address.value("county").toString();
    } else if (!address.value("state").isUndefined()) {
        region = address.value("state").toString();
    } else if (!address.value("region").isUndefined()) {
        region = address.value("region").toString();
    }

    qCDebug(logLocation) << "Location reverse geocode result:" << city << "/" << region << "/" << country;
    Location* location = new Location(latitude, longitude, city, region, country, countryCode, this);

    if (m_current) {
        if (*m_current == *location) {
            return;
        }

        m_current->deleteLater();
    }

    m_current = location;
    emit locationChanged();
}

LocationProvider::LocationProvider(QObject* parent) : QObject(parent) { m_networkManager->setAutoDeleteReplies(true); }

void LocationProvider::setupClient() {
    if (m_client) {
        qCWarning(logLocation) << "Client already created.";
        return;
    }

    auto bus = QDBusConnection::systemBus();
    if (!bus.isConnected()) {
        qCWarning(logLocation) << "Could not connect to DBus. Location will not be available.";
        return;
    }

    if (!bus.interface()->startService("org.freedesktop.GeoClue2").isValid()) {
        qCWarning(logLocation) << "Failed to start GeoClue2 service. Location will not be available.";
        return;
    }

    DBusGeoClue2Manager manager("org.freedesktop.GeoClue2", "/org/freedesktop/GeoClue2/Manager", bus, this);
    if (!manager.isValid()) {
        qCWarning(logLocation) << "Could not connect to GeoClue2. Location will not be available.";
        return;
    }

    auto reply = manager.CreateClient();
    auto watcher = new QDBusPendingCallWatcher(reply, this);
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher, bus]() {
        QDBusPendingReply<QDBusObjectPath> result = *watcher;
        if (result.isError()) {
            qCWarning(logLocation) << "Failed to create GeoClue2 client:" << result.error().message();
            watcher->deleteLater();
            return;
        }

        auto client = new DBusGeoClue2Client("org.freedesktop.GeoClue2", result.value().path(), bus, this);
        if (!client->isValid()) {
            qCWarning(logLocation) << "Created invalid GeoClue2 client.";
            watcher->deleteLater();
            return;
        }

        client->setDesktopId("shiny-shell");
        client->setRequestedAccuracyLevel(REQUESTED_ACCURACY);
        client->setDistanceThreshold(0);
        client->setTimeThreshold(TIME_THRESHOLD);

        connect(client, &DBusGeoClue2Client::LocationUpdated, this,
                [this](const QDBusObjectPath&, const QDBusObjectPath& location) { locationUpdated(location); });

        QDBusConnection::systemBus().connect(client->service(), client->path(), "org.freedesktop.DBus.Properties",
                                             "PropertiesChanged", this, SLOT(propertiesChanged(QString, QVariantMap)));

        m_client = client;
        start();
        watcher->deleteLater();
    });
}

LocationProviderQml::LocationProviderQml(QObject* parent) : QObject(parent) {
    // Connect to the singleton instance
    auto provider = LocationProvider::instance();

    // Forward signals from the singleton to this QML singleton
    connect(provider, &LocationProvider::activeChanged, this, &LocationProviderQml::activeChanged);
    connect(provider, &LocationProvider::locationChanged, this, &LocationProviderQml::locationChanged);
}

bool LocationProviderQml::active() const { return LocationProvider::instance()->active(); }

Location* LocationProviderQml::location() const { return LocationProvider::instance()->location(); }

void LocationProviderQml::start() { return LocationProvider::instance()->start(); }

void LocationProviderQml::stop() { return LocationProvider::instance()->stop(); }

void LocationProviderQml::refresh() { return LocationProvider::instance()->refresh(); }

} // namespace Shiny::Location
