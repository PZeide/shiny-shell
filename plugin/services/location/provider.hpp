#pragma once

#include "data.hpp"
#include <memory>
#include <qnetworkaccessmanager.h>
#include <qnetworkreply.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtimer.h>
#include <qtmetamacros.h>

// ipinfo has a limit of 1000 requests per day so this is a safe interval
constexpr int DEFAULT_REFRESH_INTERVAL_MSECS = 5 * 60 * 1000;

namespace Shiny::Services::Location {
  class LocationProvider : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int refreshInterval READ refreshInterval WRITE setRefreshInterval NOTIFY refreshIntervalChanged)
    Q_PROPERTY(Shiny::Services::Location::LocationData* current READ current NOTIFY currentChanged)
    // clang-format on

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
    std::unique_ptr<LocationData> m_current;

    QNetworkAccessManager m_networkManager;
    quint64 m_requestTracker = 0;
    QTimer m_refreshTimer;
  };
} // namespace Shiny::Services::Location
