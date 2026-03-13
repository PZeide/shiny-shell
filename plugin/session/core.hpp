#pragma once

#include "dbus_manager.h"
#include "dbus_session.h"
#include <qcontainerfwd.h>
#include <qdbusunixfiledescriptor.h>
#include <qfuture.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qpromise.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace Shiny::Session {

Q_DECLARE_LOGGING_CATEGORY(logSession)

class Login1Session : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool lockedHint READ lockedHint WRITE setLockedHint NOTIFY lockedHintChanged)

public:
    static Login1Session* instance();

    bool lockedHint() const;
    void setLockedHint(bool lockedHint);

    QFuture<QDBusUnixFileDescriptor> inhibit(QString what, QString why);

signals:
    void lockedHintChanged();
    void aboutToShutdown();
    void shutdownRecovered();
    void aboutToSleep();
    void sleepRecovered();
    void lockRequested();
    void unlockRequested();

private slots:
    void sessionPropertiesChanged(QString interfaceName, QVariantMap changedProperties);

private:
    explicit Login1Session(QObject* parent = nullptr);

    DBusLogin1Manager* m_manager = nullptr;
    DBusLogin1Session* m_session = nullptr;
};

class SessionManagerQml : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(SessionManager)
    QML_SINGLETON

    Q_PROPERTY(bool lockedHint READ lockedHint WRITE setLockedHint NOTIFY lockedHintChanged)

public:
    explicit SessionManagerQml(QObject* parent = nullptr);

    bool lockedHint() const;
    void setLockedHint(bool lockedHint);

signals:
    void lockedHintChanged();
    void lockRequested();
    void unlockRequested();
};

} // namespace Shiny::Session
