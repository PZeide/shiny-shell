#pragma once

#include <qcontainerfwd.h>
#include <qdbusargument.h>
#include <qdbusconnection.h>
#include <qdbusinterface.h>
#include <qdbuspendingcall.h>
#include <qdbusunixfiledescriptor.h>
#include <qloggingcategory.h>
#include <qmetaobject.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace Shiny::DBus {
  Q_DECLARE_LOGGING_CATEGORY(logLogindHandler)

  class LogindHandler : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool valid READ valid)
    Q_PROPERTY(bool sleepInhibited READ sleepInhibited WRITE setSleepInhibited NOTIFY sleepInhibitedChanged)
    Q_PROPERTY(QString sleepInhibitDescription READ sleepInhibitDescription WRITE setSleepInhibitDescription
               NOTIFY sleepInhibitDescriptionChanged)
    Q_PROPERTY(bool lockHint READ lockHint WRITE setLockHint) // No NOTIFY because the service don't monitor for external changes
    // clang-format on

  public:
    explicit LogindHandler(QObject* parent = nullptr);

    bool valid() const;

    bool sleepInhibited() const;
    void setSleepInhibited(bool sleepInhibited);

    QString sleepInhibitDescription() const;
    void setSleepInhibitDescription(QString sleepInhibitDescription);

    bool lockHint() const;
    void setLockHint(bool lockHint);

  signals:
    void sleepInhibitedChanged();
    void sleepInhibitDescriptionChanged();
    void aboutToSleep();
    void resumedFromSleep();
    void lockRequested();
    void unlockRequested();

  private slots:
    void handleInhibitSleepCall(QDBusPendingCallWatcher* watcher);
    void handlePrepareForSleep(bool start);

  private:
    QDBusConnection m_connection = QDBusConnection::systemBus();
    QString m_sessionPath;
    bool m_prepareForSleepBound = false;
    bool m_lockBound = false;
    bool m_unlockBound = false;
    QDBusUnixFileDescriptor m_sleepInhibitFd;
    QString m_sleepInhibitDescription = "Cleanup before sleep";

    void connectNotify(const QMetaMethod& signal) override;
    void bindPrepareForSleep();
    void bindLock();
    void bindUnlock();
  };
}
