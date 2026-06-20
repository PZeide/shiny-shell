#pragma once

#include "dbus_client.h"
#include "location.hpp"
#include <qcontainerfwd.h>
#include <qdbusextratypes.h>
#include <qloggingcategory.h>
#include <qnetworkaccessmanager.h>
#include <qnetworkreply.h>
#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Location {

Q_DECLARE_LOGGING_CATEGORY(logLocation)

// Request exact accuracy
constexpr uint REQUESTED_ACCURACY = 8;
// Only emit location update every 5 minutes
constexpr uint TIME_THRESHOLD = 6 * 60;

class LocationProvider : public QObject {
    Q_OBJECT

    // clang-format off
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(Shiny::Location::Location* location READ location NOTIFY locationChanged)
    // clang-format on

public:
    static LocationProvider* instance();

    bool active() const;
    Location* location() const;

    void start();
    void stop();
    void refresh();

signals:
    void activeChanged();
    void locationChanged();

private slots:
    void propertiesChanged(QString interfaceName, QVariantMap changedProperties);
    void locationUpdated(const QDBusObjectPath& location);
    void handleReverseGeocodingReply(QNetworkReply* reply, double latitude, double longitude);

private:
    explicit LocationProvider(QObject* parent = nullptr);

    void setupClient();

    DBusGeoClue2Client* m_client = nullptr;
    Location* m_current = nullptr;
    QNetworkAccessManager* m_networkManager = new QNetworkAccessManager(this);
};

class LocationProviderQml : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(LocationProvider)
    QML_SINGLETON

    // clang-format off
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(Shiny::Location::Location* location READ location NOTIFY locationChanged)
    // clang-format on

public:
    explicit LocationProviderQml(QObject* parent = nullptr);

    bool active() const;
    Location* location() const;

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void refresh();

signals:
    void activeChanged();
    void locationChanged();
};

} // namespace Shiny::Location
