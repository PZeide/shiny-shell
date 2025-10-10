#pragma once

#include "data.hpp"
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QTimer>
#include <QtQmlIntegration>
#include <memory>

// ipinfo has a limit of 1000 requests per day so this is a safe interval
constexpr int DEFAULT_REFRESH_INTERVAL_MSECS = 5 * 60 * 1000;

namespace Shiny::Services::Location {
  class LocationProvider : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int refreshInterval READ refreshInterval WRITE setRefreshInterval NOTIFY refreshIntervalChanged)
    Q_PROPERTY(Shiny::Services::Location::LocationData* current READ current NOTIFY currentChanged)

  public:
    explicit LocationProvider(QObject* parent = nullptr);

    [[nodiscard]] bool enabled() const;
    void setEnabled(bool enabled);

    [[nodiscard]] int refreshInterval() const;
    void setRefreshInterval(int refreshInterval);

    [[nodiscard]] LocationData* current() const;

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
    QNetworkAccessManager m_networkManager = QNetworkAccessManager(this);
    quint64 m_requestTracker = 0;
    QTimer m_refreshTimer;
    std::unique_ptr<LocationData> m_current;
  };
} // namespace Shiny::Services::Location
