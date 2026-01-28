#include "logindmanager.hpp"
#include "dbus.hpp"
#include <QDBusReply>

namespace Shiny::DBus {
  Q_LOGGING_CATEGORY(logLogindManager, "shiny.dbus.logindmanager", QtInfoMsg)

  LogindManager::LogindManager(QObject* parent) : QObject(parent) {
    if (!m_connection.isConnected()) {
      qCWarning(logLogindManager) << "System bus is not available";
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
      qCWarning(logLogindManager) << "Failed to get session path";
      return;
    }

    m_sessionPath = reply.value().path();
    qCDebug(logLogindManager) << "Session path:" << m_sessionPath;

    m_connection.connect(
      LOGIN1_SERVICE,
      LOGIN1_PATH,
      LOGIN1_MANAGER_INTERFACE,
      "PrepareForSleep",
      this,
      SLOT(handlePrepareForSleep(bool))
    );

    m_connection.connect(
      LOGIN1_SERVICE,
      m_sessionPath,
      LOGIN1_SESSION_INTERFACE,
      "Lock",
      this,
      SLOT(handleLockRequest())
    );

    m_connection.connect(
      LOGIN1_SERVICE,
      m_sessionPath,
      LOGIN1_SESSION_INTERFACE,
      "Unlock",
      this,
      SLOT(handleUnlockRequest())
    );
  }

  QBindable<bool> LogindManager::bindableLockHint() const {
    return &this->b_lockHint;
  }

  void LogindManager::setLockHint(bool lockHint) {
    if (*this->b_lockHint == lockHint) {
      return;
    }

    if (m_sessionPath.isEmpty()) {
      qCWarning(logLogindManager) << "Session path is invalid";
      return;
    }

    QDBusMessage message = QDBusMessage::createMethodCall(
      LOGIN1_SERVICE,
      m_sessionPath,
      LOGIN1_SESSION_INTERFACE,
      "SetLockedHint"
    );

    message.setArguments({lockHint});
    m_connection.call(message, QDBus::NoBlock);

    this->b_lockHint = lockHint;
  }

  void LogindManager::handlePrepareForSleep(bool start) {
    if (start) {
      emit aboutToSleep();
    } else {
      emit resumedFromSleep();
    }
  }

  void LogindManager::handleLockRequest() {
    emit lockRequested();
  }

  void LogindManager::handleUnlockRequest() {
    emit unlockRequested();
  }
}
