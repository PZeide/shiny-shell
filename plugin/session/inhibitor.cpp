#include "inhibitor.hpp"

#include "core.hpp"
#include <qcontainerfwd.h>
#include <qdbusunixfiledescriptor.h>
#include <qhashfunctions.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qtmetamacros.h>

namespace Shiny::Session {

Q_LOGGING_CATEGORY(logSessionInhibitor, "shiny.session.inhibitor", QtInfoMsg)

QString InhibitorLock::typeToWhat(Type type) {
    switch (type) {
    case Shutdown:
        return QStringLiteral("shutdown");
    case Sleep:
        return QStringLiteral("sleep");
    default:
        return QStringLiteral("unknown");
    }
}

InhibitorLock::InhibitorLock(QObject* parent) : QObject(parent) {}

void InhibitorLock::componentComplete() {
    if ((*b_description).isEmpty()) {
        qCCritical(logSessionInhibitor) << "Cannot create an inhibitor lock with an empty description!";
        return;
    }

    if (b_type == Type::Shutdown) {
        connect(Login1Session::instance(), &Login1Session::aboutToShutdown, this, &InhibitorLock::actionRequired);
        connect(Login1Session::instance(), &Login1Session::shutdownRecovered, this, &InhibitorLock::requestLockFd);
    } else if (b_type == Type::Sleep) {
        connect(Login1Session::instance(), &Login1Session::aboutToSleep, this, &InhibitorLock::actionRequired);
        connect(Login1Session::instance(), &Login1Session::sleepRecovered, this, &InhibitorLock::requestLockFd);
    }

    requestLockFd();
}

bool InhibitorLock::active() const { return m_currentFd.isValid(); }

QBindable<QString> InhibitorLock::bindableDescription() { return &b_description; }

QBindable<InhibitorLock::Type> InhibitorLock::bindableType() { return &b_type; }

void InhibitorLock::release() {
    if (!m_currentFd.isValid()) {
        qCWarning(logSessionInhibitor) << "Cannot release inhibitor lock because it is not active!";
        return;
    }

    m_currentFd = QDBusUnixFileDescriptor();
    emit activeChanged();
}

void InhibitorLock::requestLockFd() {
    if (m_currentFd.isValid()) {
        qCWarning(logSessionInhibitor) << "Last inhibitor lock still exists, the action might have been too long!";
        m_currentFd = QDBusUnixFileDescriptor();
        emit activeChanged();
    }

    auto future = Login1Session::instance()->inhibit(typeToWhat(b_type), b_description);
    future
        .then([this](QDBusUnixFileDescriptor descriptor) {
            qCInfo(logSessionInhibitor) << "Received inhibitor lock descriptor";
            m_currentFd.swap(descriptor);
            emit activeChanged();
        })
        .onFailed([] { qCCritical(logSessionInhibitor) << "Failed to capture inhibitor lock!"; });
}

} // namespace Shiny::Session
