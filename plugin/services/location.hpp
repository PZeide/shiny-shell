#pragma once

#include <memory>
#include <qloggingcategory.h>
#include <qnetworkaccessmanager.h>
#include <qnetworkreply.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtimer.h>
#include <qtmetamacros.h>
#include <qtypes.h>

// ipinfo has a limit of 1000 requests per day so this is a safe interval
constexpr int LOCATION_DEFAULT_REFRESH_INTERVAL_MSECS = 5 * 60 * 1000;

namespace Shiny::Services {
  Q_DECLARE_LOGGING_CATEGORY(logLocation)

  class LocationData : public QObject {
    Q_OBJECT
    QML_ANONYMOUS

    // clang-format off
    Q_PROPERTY(qreal latitude READ latitude CONSTANT)
    Q_PROPERTY(qreal longitude READ longitude CONSTANT)
    Q_PROPERTY(QString countryCode READ countryCode CONSTANT)
    Q_PROPERTY(QString countryName READ countryName CONSTANT)
    Q_PROPERTY(QString city READ city CONSTANT)
    // clang-format on

  public:
    explicit LocationData(
      qreal latitude,
      qreal longitude,
      QString countryCode,
      QString countryName,
      QString city,
      QObject* parent = nullptr
    );

    qreal latitude() const;
    qreal longitude() const;
    QString countryCode() const;
    QString countryName() const;
    QString city() const;

    bool operator==(const LocationData& other) const;

  private:
    qreal m_latitude;
    qreal m_longitude;
    QString m_countryCode;
    QString m_countryName;
    QString m_city;
  };

  class LocationProvider : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int refreshInterval READ refreshInterval WRITE setRefreshInterval NOTIFY refreshIntervalChanged)
    Q_PROPERTY(Shiny::Services::LocationData* current READ current NOTIFY currentChanged)
    // clang-format on

  public:
    explicit LocationProvider(QObject* parent = nullptr);

    bool enabled() const;
    void setEnabled(bool enabled);

    int refreshInterval() const;
    void setRefreshInterval(int refreshInterval);

    LocationData* current() const;

  public slots:
    Q_INVOKABLE void refresh();

  private slots:
    void result(QNetworkReply* reply);

  signals:
    void enabledChanged();
    void refreshIntervalChanged();
    void currentChanged();

  private:
    bool m_enabled = false;
    std::unique_ptr<LocationData> m_current;
    QNetworkAccessManager m_networkManager;
    quint64 m_requestTracker = 0;
    QTimer m_refreshTimer;
  };
}
