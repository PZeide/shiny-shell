#include "provider.hpp"
#include <memory>
#include <qbytearray.h>
#include <qcontainerfwd.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <qlocale.h>
#include <qlogging.h>
#include <qnetworkrequest.h>
#include <qurl.h>

namespace Shiny::Services::Location {
  LocationProvider::LocationProvider(QObject* parent) : QObject(parent) {
    connect(&m_networkManager, &QNetworkAccessManager::finished, this, &LocationProvider::result);
    m_networkManager.setAutoDeleteReplies(true);

    connect(&m_refreshTimer, &QTimer::timeout, this, &LocationProvider::refresh);
    m_refreshTimer.setTimerType(Qt::CoarseTimer);
    m_refreshTimer.setSingleShot(false);
    m_refreshTimer.setInterval(DEFAULT_REFRESH_INTERVAL_MSECS);
  }

  bool LocationProvider::enabled() const {
    return m_enabled;
  }

  void LocationProvider::setEnabled(bool enabled) {
    if (m_enabled == enabled)
      return;

    m_enabled = enabled;
    emit enabledChanged();

    if (enabled) {
      m_refreshTimer.start();
    } else {
      m_refreshTimer.stop();

      if (m_current) {
        m_current = nullptr;
        emit currentChanged();
      }
    }
  }

  int LocationProvider::refreshInterval() const {
    return m_refreshTimer.interval();
  }

  void LocationProvider::setRefreshInterval(int refreshInterval) {
    if (m_refreshTimer.interval() == refreshInterval)
      return;

    m_refreshTimer.setInterval(refreshInterval);
    emit refreshIntervalChanged();
  }

  LocationData* LocationProvider::current() const {
    return m_current.get();
  }

  void LocationProvider::refresh() {
    if (!m_enabled)
      return;

    QUrl url("https://ipinfo.io/json");
    QNetworkRequest request(url);
    QNetworkReply* reply = m_networkManager.get(request);
    reply->setProperty("tracker", ++m_requestTracker);
  }

  void LocationProvider::result(QNetworkReply* reply) {
    if (!m_enabled)
      return;

    if (reply->error() != QNetworkReply::NoError) {
      qWarning() << "Failed to fetch location:" << reply->errorString();
      return;
    }

    QByteArray response = reply->readAll();
    QJsonDocument json = QJsonDocument::fromJson(response);

    if (!json.isObject()) {
      qWarning() << "Failed to fetch location: response is not valid json object";
      return;
    }

    QJsonObject object = json.object();

    QString location = object.value("loc").toString();
    QStringList values = location.split(",");
    qreal latitude = values.value(0).toDouble();
    qreal longitude = values.value(1).toDouble();

    QString countryCode = object.value("country").toString();
    QLocale::Territory territory = QLocale::codeToTerritory(countryCode);
    QString countryName;
    if (territory == QLocale::AnyTerritory) {
      countryName = "Unknown country";
    } else {
      countryName = QLocale::territoryToString(territory);
    }

    QString city = object.value("city").toString();

    m_current = std::make_unique<LocationData>(latitude, longitude, countryCode, countryName, city);
    emit currentChanged();
  }
} // namespace Shiny::Services::Location
