#include "logindhandler.hpp"
#include <qdbusconnection.h>
#include <qdbuserror.h>
#include <qdbusextratypes.h>
#include <qdbusinterface.h>
#include <qdbusmessage.h>
#include <qdbusreply.h>
#include <qdbusunixfiledescriptor.h>
#include <qlogging.h>
#include <qobject.h>
#include <unistd.h>

namespace Shiny::DBus {
  Q_LOGGING_CATEGORY(logLogindHandler, "shiny.dbus.logindhandler", QtInfoMsg)

  const static QString LOGIN1_SERVICE = QStringLiteral("org.freedesktop.login1");
  const static QString LOGIN1_PATH = QStringLiteral("/org/freedesktop/login1");
  const static QString LOGIN1_MANAGER_INTERFACE = QStringLiteral("org.freedesktop.login1.Manager");
  const static QString LOGIN1_SESSION_INTERFACE = QStringLiteral("org.freedesktop.login1.Session");
  const static QString PROPERTY_INTERFACE = QStringLiteral("org.freedesktop.DBus.Properties");

  LogindHandler::LogindHandler(QObject* parent) : QObject(parent) {
    if (!m_connection.isConnected()) {
      qCWarning(logLogindHandler) << "System bus is not available";
      return;
    }

    QDBusMessage message = QDBusMessage::createMethodCall(
      LOGIN1_SERVICE,
      LOGIN1_PATH,
      LOGIN1_MANAGER_INTERFACE,
      "GetSession"
    );

    message.setArguments({"auto"});
    QDBusReply<QDBusObjectPath> reply = m_connection.call(message);
    if (!reply.isValid()) {
      qCWarning(logLogindHandler) << "Failed to get session path";
      return;
    }

    m_sessionPath = reply.value().path();
  }

  bool LogindHandler::valid() const {
    return m_connection.isConnected() && !m_sessionPath.isEmpty();
  }

  bool LogindHandler::sleepInhibited() const {
    return m_sleepInhibitFd.isValid();
  }

  void LogindHandler::setSleepInhibited(bool sleepInhibited) {
    if (sleepInhibited) {
      if (m_sleepInhibitFd.isValid())
        return;

      QDBusMessage message = QDBusMessage::createMethodCall(
        LOGIN1_SERVICE,
        LOGIN1_PATH,
        LOGIN1_MANAGER_INTERFACE,
        "Inhibit"
      );

      message.setArguments({"sleep", "shiny-shell", m_sleepInhibitDescription, "delay"});
      QDBusPendingReply<QDBusUnixFileDescriptor> reply = m_connection.asyncCall(message);
      QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(reply, this);

      connect(
        watcher,
        &QDBusPendingCallWatcher::finished,
        this,
        &LogindHandler::handleInhibitSleepCall
      );
    } else {
      if (!m_sleepInhibitFd.isValid())
        return;

      m_sleepInhibitFd = QDBusUnixFileDescriptor();
    }
  }

  QString LogindHandler::sleepInhibitDescription() const {
    return m_sleepInhibitDescription;
  }

  void LogindHandler::setSleepInhibitDescription(QString sleepInhibitDescription) {
    if (m_sleepInhibitDescription == sleepInhibitDescription)
      return;

    m_sleepInhibitDescription = sleepInhibitDescription;
    emit sleepInhibitDescriptionChanged();

    if (m_sleepInhibitFd.isValid()) {
      // Dirty way to update the description
      setSleepInhibited(false);
      setSleepInhibited(true);
    }
  }

  bool LogindHandler::lockHint() const {
    if (!valid())
      return false;

    QDBusMessage message = QDBusMessage::createMethodCall(
      LOGIN1_SERVICE,
      m_sessionPath,
      PROPERTY_INTERFACE,
      "SetLockedHint"
    );

    message.setArguments({LOGIN1_SESSION_INTERFACE, "LockedHint"});
    QDBusReply<QDBusVariant> reply = m_connection.call(message);
    if (!reply.isValid()) {
      qCWarning(logLogindHandler) << "Failed to get lock hint";
      return false;
    }

    return reply.value().variant().toBool();
  }

  void LogindHandler::setLockHint(bool lockHint) {
    if (!valid())
      return;

    QDBusMessage message = QDBusMessage::createMethodCall(
      LOGIN1_SERVICE,
      m_sessionPath,
      LOGIN1_SESSION_INTERFACE,
      "SetLockedHint"
    );

    message.setArguments({lockHint});
    m_connection.call(message, QDBus::NoBlock);
  }

  void LogindHandler::handleInhibitSleepCall(QDBusPendingCallWatcher* watcher) {
    if (m_sleepInhibitFd.isValid())
      return;

    QDBusPendingReply<QDBusUnixFileDescriptor> reply = *watcher;
    watcher->deleteLater();

    if (!reply.isValid()) {
      qCWarning(logLogindHandler) << "Failed to inhibit sleep";
      return;
    }

    reply.value().swap(m_sleepInhibitFd);
    emit sleepInhibitedChanged();
  }

  void LogindHandler::handlePrepareForSleep(bool start) {
    if (start) {
      emit aboutToSleep();
    } else {
      emit resumedFromSleep();
    }
  }

  void LogindHandler::connectNotify(const QMetaMethod& signal) {
    const QByteArray name = signal.name();

    if (name == "aboutToSleep" || name == "resumedFromSleep") {
      bindPrepareForSleep();
    } else if (name == "lockRequested") {
      bindLock();
    } else if (name == "unlockRequested") {
      bindUnlock();
    }
  }

  void LogindHandler::bindPrepareForSleep() {
    if (m_prepareForSleepBound || !this->valid())
      return;

    m_prepareForSleepBound = m_connection.connect(
      LOGIN1_SERVICE,
      LOGIN1_PATH,
      LOGIN1_MANAGER_INTERFACE,
      "PrepareForSleep",
      this,
      SLOT(handlePrepareForSleep(bool))
    );

    if (!m_prepareForSleepBound)
      qCWarning(logLogindHandler) << "Failed to bind to PrepareForSleep signal";
  }

  void LogindHandler::bindLock() {
    if (m_lockBound || !this->valid())
      return;

    m_lockBound = m_connection.connect(
      LOGIN1_SERVICE,
      m_sessionPath,
      LOGIN1_SESSION_INTERFACE,
      "Lock",
      this,
      SIGNAL(lockRequested())
    );

    if (!m_lockBound)
      qCWarning(logLogindHandler) << "Failed to bind to Lock signal";
  }

  void LogindHandler::bindUnlock() {
    if (m_unlockBound || !this->valid())
      return;

    m_unlockBound = m_connection.connect(
      LOGIN1_SERVICE,
      m_sessionPath,
      LOGIN1_SESSION_INTERFACE,
      "Unlock",
      this,
      SIGNAL(unlockRequested())
    );

    if (!m_unlockBound)
      qCWarning(logLogindHandler) << "Failed to bind to Unlock signal";
  }
}
