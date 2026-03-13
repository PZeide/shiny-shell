#pragma once

#include <qcontainerfwd.h>
#include <qdbusunixfiledescriptor.h>
#include <qhashfunctions.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qqmlparserstatus.h>
#include <qtmetamacros.h>

namespace Shiny::Session {

Q_DECLARE_LOGGING_CATEGORY(logSessionInhibitor)

class InhibitorLock : public QObject, public QQmlParserStatus {
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(QString description READ default WRITE default BINDABLE bindableDescription REQUIRED)
    Q_PROPERTY(Shiny::Session::InhibitorLock::Type type READ default WRITE default BINDABLE bindableType REQUIRED)
    // clang-format on

public:
    enum Type { Shutdown, Sleep };
    Q_ENUM(Type)

    static QString typeToWhat(Type type);

    explicit InhibitorLock(QObject* parent = nullptr);

    void classBegin() override {};
    void componentComplete() override;

    bool active() const;
    QBindable<QString> bindableDescription();
    QBindable<Type> bindableType();

    Q_INVOKABLE void release();

signals:
    void activeChanged();
    void actionRequired();

private slots:
    void requestLockFd();

private:
    QDBusUnixFileDescriptor m_currentFd;

    // clang-format off
    Q_OBJECT_BINDABLE_PROPERTY(InhibitorLock, QString, b_description, &InhibitorLock::activeChanged)
    Q_OBJECT_BINDABLE_PROPERTY(InhibitorLock, Type, b_type)
    // clang-format on
};

} // namespace Shiny::Session
