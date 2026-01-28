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
#include <qproperty.h>

namespace Shiny::DBus {
  Q_DECLARE_LOGGING_CATEGORY(logLogindHandler)

  class LogindHandler : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool valid READ valid CONSTANT)
    Q_PROPERTY(QString sleepInhibitDescription BINDABLE sleepInhibitDescriptionBindable FINAL)
    Q_PROPERTY(bool sleepInhibited BINDABLE sleepInhibitedBindable)
    Q_PROPERTY(bool lockHint BINDABLE lockHintBindable)
    // clang-format on

  public:
    explicit LogindHandler(QObject* parent = nullptr);
    ~LogindHandler() override = default;

    [[nodiscard]] bool valid() const;

    QProperty<bool> sleepInhibited{this, "sleepInhibited", false};

    /** @brief Inhibit or uninhibit sleep */
    Q_INVOKABLE void setSleepInhibited(bool sleepInhibited);

    /** @brief Sleep inhibit description property */
    QProperty<QString> sleepInhibitDescription{
      this,
      "sleepInhibitDescription",
      QStringLiteral("Cleanup before sleep")
    };

    /** @brief Sets the sleep inhibit description */
    Q_INVOKABLE void setSleepInhibitDescription(QStringView sleepInhibitDescription);

    /** @brief Lock hint state property */
    QProperty<bool> lockHint{this, "lockHint", false};

    /** @brief Sets the lock hint */
    Q_INVOKABLE void setLockHint(bool lockHint);

  signals:
    void validChanged();
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
    QDBusConnection m_connection{QDBusConnection::systemBus()};
    QString m_sessionPath;
    bool m_prepareForSleepBound = false;
    bool m_lockBound = false;
    bool m_unlockBound = false;
    QDBusUnixFileDescriptor m_sleepInhibitFd;

    Q_OBJECT_BINDABLE_PROPERTY(LogindHandler, QString, sleepInhibitDescriptionBindable)

    void connectNotify(const QMetaMethod& signal) override;
    void bindPrepareForSleep();
    void bindLock();
    void bindUnlock();
  };
}
