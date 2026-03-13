#include "core.hpp"

#include "dbus_manager.h"
#include "dbus_session.h"
#include <exception>
#include <qcontainerfwd.h>
#include <qdbusconnection.h>
#include <qdbusextratypes.h>
#include <qdbusmetatype.h>
#include <qdbuspendingcall.h>
#include <qdbuspendingreply.h>
#include <qdbusunixfiledescriptor.h>
#include <qfuture.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qpromise.h>
#include <qtmetamacros.h>

namespace Shiny::Session {

Q_LOGGING_CATEGORY(logSession, "shiny.session", QtInfoMsg)

Login1Session* Login1Session::instance() {
    static Login1Session* instance = new Login1Session();
    return instance;
}

bool Login1Session::lockedHint() const {
    if (!m_session) {
        qCWarning(logSession) << "Could not get locked hint. Session is not available.";
        return false;
    }

    return m_session->lockedHint();
}

void Login1Session::setLockedHint(bool lockedHint) {
    if (!m_session) {
        qCWarning(logSession) << "Could not set locked hint. Session is not available.";
        return;
    }

    auto reply = m_session->SetLockedHint(lockedHint);
    auto watcher = new QDBusPendingCallWatcher(reply, this);
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, this, [watcher]() {
        QDBusPendingReply<QDBusObjectPath> result = *watcher;
        if (result.isError()) {
            qCWarning(logSession) << "Failed to set locked hint:" << result.error().message();
            return;
        }

        watcher->deleteLater();
    });
}

QFuture<QDBusUnixFileDescriptor> Login1Session::inhibit(QString what, QString why) {
    if (!m_manager) {
        qCWarning(logSession) << "Could not inhibit. Session is not available.";
        return QtFuture::makeExceptionalFuture<QDBusUnixFileDescriptor>(
            std::make_exception_ptr("Session is not available"));
    }

    auto reply = m_manager->Inhibit(what, "Shiny Shell", why, "delay");
    auto watcher = new QDBusPendingCallWatcher(reply, this);
    return QtFuture::connect(watcher, &QDBusPendingCallWatcher::finished).then([watcher](QDBusPendingCallWatcher*) {
        QDBusPendingReply<QDBusUnixFileDescriptor> result = *watcher;
        watcher->deleteLater();

        if (result.isError()) {
            throw result.error();
        }

        return result.value();
    });
}

void Login1Session::sessionPropertiesChanged(QString, QVariantMap changedProperties) {
    if (changedProperties.contains("LockedHint")) {
        emit lockedHintChanged();
    }
}

Login1Session::Login1Session(QObject* parent) : QObject(parent) {
    auto bus = QDBusConnection::systemBus();
    if (!bus.isConnected()) {
        qCWarning(logSession) << "Could not connect to DBus. Session handler will not be available.";
        return;
    }

    DBusLogin1Manager* manager = new DBusLogin1Manager("org.freedesktop.login1", "/org/freedesktop/login1", bus, this);
    if (!manager->isValid()) {
        qCWarning(logSession) << "Failed to get manager!";
        return;
    }

    m_manager = manager;

    connect(manager, &DBusLogin1Manager::PrepareForShutdown, this, [this](bool start) {
        if (start) {
            emit aboutToShutdown();
        } else {
            emit shutdownRecovered();
        }
    });

    connect(manager, &DBusLogin1Manager::PrepareForSleep, this, [this](bool start) {
        if (start) {
            emit aboutToSleep();
        } else {
            emit sleepRecovered();
        }
    });

    // We want a blocking call here to make sure that everything is initialized
    auto reply = manager->GetSession("auto");
    reply.waitForFinished();

    if (reply.isError()) {
        qCWarning(logSession) << "Failed to get session path:" << reply.error().message();
        return;
    }

    DBusLogin1Session* session = new DBusLogin1Session("org.freedesktop.login1", reply.value().path(), bus, this);
    if (!session->isValid()) {
        qCWarning(logSession) << "Failed to get session!";
        return;
    }

    m_session = session;
    connect(session, &DBusLogin1Session::Lock, this, &Login1Session::lockRequested);
    connect(session, &DBusLogin1Session::Unlock, this, &Login1Session::unlockRequested);
    bus.connect(session->service(), session->path(), "org.freedesktop.DBus.Properties", "PropertiesChanged", this,
                SLOT(sessionPropertiesChanged(QString, QVariantMap)));
}

SessionManagerQml::SessionManagerQml(QObject* parent) : QObject(parent) {
    // Connect to the singleton instance
    auto login1 = Login1Session::instance();

    // Forward signals from the singleton to this QML singleton
    connect(login1, &Login1Session::lockedHintChanged, this, &SessionManagerQml::lockedHintChanged);
    connect(login1, &Login1Session::lockRequested, this, &SessionManagerQml::lockRequested);
    connect(login1, &Login1Session::unlockRequested, this, &SessionManagerQml::unlockRequested);
}

bool SessionManagerQml::lockedHint() const { return Login1Session::instance()->lockedHint(); }

void SessionManagerQml::setLockedHint(bool lockedHint) { Login1Session::instance()->setLockedHint(lockedHint); }

} // namespace Shiny::Session
