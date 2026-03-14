#pragma once

#include <qcontainerfwd.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace Shiny::Greeter {

Q_DECLARE_LOGGING_CATEGORY(logGreeterHelpers)

class SessionDesktopEntry : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("SessionDesktopEntry is retrieved from GreeterHelpers")

    Q_PROPERTY(QList<QString> command READ command CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString desktopName READ desktopName CONSTANT)

public:
    explicit SessionDesktopEntry(QList<QString> command, QString name, QString desktopName, QObject* parent = nullptr);

    QList<QString> command() const;
    QString name() const;
    QString desktopName() const;

    bool operator==(const SessionDesktopEntry& other) const;
    bool operator!=(const SessionDesktopEntry& other) const;

private:
    const QList<QString> m_command;
    const QString m_name;
    const QString m_desktopName;
};

class GreeterHelpers : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit GreeterHelpers(QObject* parent = nullptr);

    Q_INVOKABLE SessionDesktopEntry* findSession(const QString& session);
};

} // namespace Shiny::Greeter
