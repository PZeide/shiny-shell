#pragma once

#include "data.hpp"
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QTimer>
#include <QtQmlIntegration>
#include <QtTypes>
#include <memory>
#include <qtypes.h>

// open-meteo has a really generous limit so we can ask for meteo updates every 3 minutes
constexpr int DEFAULT_REFRESH_INTERVAL_MSECS = 3 * 60 * 1000;

namespace Shiny::Services::Weather {
  class WeatherProvider : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int refreshInterval READ refreshInterval WRITE setRefreshInterval NOTIFY refreshIntervalChanged)
    Q_PROPERTY(qreal latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged)
    Q_PROPERTY(qreal longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)
    Q_PROPERTY(Shiny::Services::Weather::WeatherData* now READ now NOTIFY nowChanged)

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
    QNetworkAccessManager m_networkManager = QNetworkAccessManager(this);
    quint64 m_requestTracker = 0;
    QTimer m_refreshTimer;
    qreal m_latitude = 0;
    qreal m_longitude = 0;
    std::unique_ptr<WeatherData> m_now;
  };
} // namespace Shiny::Services::Weather
