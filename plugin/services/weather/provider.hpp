#pragma once

#include "data.hpp"
#include <memory>
#include <qnetworkaccessmanager.h>
#include <qnetworkreply.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtimer.h>
#include <qtmetamacros.h>
#include <qtypes.h>

// open-meteo has a really generous limit so we can ask for meteo updates every 3 minutes
constexpr int DEFAULT_REFRESH_INTERVAL_MSECS = 3 * 60 * 1000;
const QString OPEN_METEO_URL_TEMPLATE =
  "https://api.open-meteo.com/v1/"
  "forecast?latitude=%1&longitude=%2&current=temperature_2m,weather_code,is_day";

namespace Shiny::Services::Weather {
  class WeatherProvider : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int refreshInterval READ refreshInterval WRITE setRefreshInterval NOTIFY refreshIntervalChanged)
    Q_PROPERTY(qreal latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged REQUIRED)
    Q_PROPERTY(qreal longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged REQUIRED)
    Q_PROPERTY(Shiny::Services::Weather::WeatherData*now READ now NOTIFY nowChanged)
    // clang-format on

  public:
    explicit WeatherProvider(QObject* parent = nullptr);

    [[nodiscard]] bool enabled() const;
    void setEnabled(bool enabled);

    [[nodiscard]] int refreshInterval() const;
    void setRefreshInterval(int refreshInterval);

    [[nodiscard]] qreal latitude() const;
    void setLatitude(qreal latitude);

    [[nodiscard]] qreal longitude() const;
    void setLongitude(qreal longitude);

    [[nodiscard]] WeatherData* now() const;

  public slots:
    Q_INVOKABLE void refresh();

  private slots:
    void result(QNetworkReply* reply);

  signals:
    void enabledChanged();
    void refreshIntervalChanged();
    void latitudeChanged();
    void longitudeChanged();
    void nowChanged();

  private:
    bool m_enabled = false;
    qreal m_latitude = 0;
    qreal m_longitude = 0;
    std::unique_ptr<WeatherData> m_now;

    QNetworkAccessManager m_networkManager;
    quint64 m_requestTracker = 0;
    QTimer m_refreshTimer;
  };
} // namespace Shiny::Services::Weather
