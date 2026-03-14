#include "helpers.hpp"

#include <qcontainerfwd.h>
#include <qdebug.h>
#include <qdir.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qtenvironmentvariables.h>

namespace Shiny::Greeter {

Q_LOGGING_CATEGORY(logGreeterHelpers, "shiny.greeter.helpers", QtInfoMsg)

SessionDesktopEntry::SessionDesktopEntry(QList<QString> command, QString name, QString desktopName, QObject* parent)
    : QObject(parent), m_command(command), m_name(name), m_desktopName(desktopName) {}

QList<QString> SessionDesktopEntry::command() const { return m_command; }

QString SessionDesktopEntry::name() const { return m_name; }

QString SessionDesktopEntry::desktopName() const { return m_desktopName; }

bool SessionDesktopEntry::operator==(const SessionDesktopEntry& other) const {
    return other.m_command == this->m_command && other.m_name == this->m_name &&
           other.m_desktopName == this->m_desktopName;
}

bool SessionDesktopEntry::operator!=(const SessionDesktopEntry& other) const { return !(*this == other); }

GreeterHelpers::GreeterHelpers(QObject* parent) : QObject(parent) {}

SessionDesktopEntry* GreeterHelpers::findSession(const QString& session) {
    qCInfo(logGreeterHelpers) << "Searching for session" << session;

    QStringList searchPaths;
    if (qEnvironmentVariableIsSet("XDG_DATA_DIRS")) {
        searchPaths << qEnvironmentVariable("XDG_DATA_DIRS").split(':');
    } else {
        qCWarning(logGreeterHelpers) << "XDG_DATA_DIRS not set, using default search path";
        searchPaths << "/usr/share/sessions" << "/usr/local/share/sessions";
    }

    for (const QString& path : searchPaths) {
        const QString sessionPath = path + "/wayland-sessions/" + session + ".desktop";

        QFile sessionFile(sessionPath);
        if (!sessionFile.open(QIODevice::ReadOnly)) {
            continue;
        }

        QTextStream stream(&sessionFile);
        QString exec, name, desktopName;
        while (!stream.atEnd()) {
            const QString line = stream.readLine();
            if (line.startsWith("Exec=")) {
                exec = line.mid(5);
            } else if (line.startsWith("Name=")) {
                name = line.mid(5);
            } else if (line.startsWith("DesktopNames=")) {
                desktopName = line.mid(13);
            }
        }

        if (exec.isEmpty() || name.isEmpty()) {
            qCWarning(logGreeterHelpers) << "Session" << session << "desktop file is invalid";
            continue;
        }

        QList<QString> command = exec.split(' ');
        return new SessionDesktopEntry(command, name, desktopName, this);
    }

    return nullptr;
}

} // namespace Shiny::Greeter
