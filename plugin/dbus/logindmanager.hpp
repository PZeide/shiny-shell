#pragma once

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusUnixFileDescriptor>
#include <QLoggingCategory>
#include <QObject>
#include <QProperty>
#include <QQmlEngine>
#include <QStringView>
#include <QtQmlIntegration>

namespace Shiny::DBus {
  Q_DECLARE_LOGGING_CATEGORY(logLogindManager)

  class LogindManager : public QObject {
    Q_OBJECT
    QML_SINGLETON

    // clang-format off
    Q_PROPERTY(bool lockHint READ default WRITE setLockHint NOTIFY lockHintChanged BINDABLE bindableLockHint)
    // clang-format on

  public:
    explicit LogindManager(QObject* parent = nullptr);
    ~LogindManager() override = default;

    [[nodiscard]] QBindable<bool> bindableLockHint() const;
    void setLockHint(bool lockHint);

  signals:
    void aboutToSleep();
    void resumedFromSleep();
    void lockRequested();
    void unlockRequested();

    void lockHintChanged();

  private slots:
    void handlePrepareForSleep(bool start);
    void handleLockRequest();
    void handleUnlockRequest();

  private:
    QDBusConnection m_connection{QDBusConnection::systemBus()};
    QString m_sessionPath{};

    // clang-format off
    Q_OBJECT_BINDABLE_PROPERTY(LogindManager, bool, b_lockHint, &LogindManager::lockHintChanged)
    // clang-format on
  };
}
