#pragma once

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusObjectPath>
#include <QDBusReply>
#include <QLoggingCategory>
#include <QString>

namespace Shiny::DBus {
  Q_LOGGING_CATEGORY(logDBus, "shiny.dbus", QtInfoMsg)

  const static QString LOGIN1_SERVICE = QStringLiteral("org.freedesktop.login1");
  const static QString LOGIN1_PATH = QStringLiteral("/org/freedesktop/login1");
  const static QString LOGIN1_MANAGER_INTERFACE = QStringLiteral("org.freedesktop.login1.Manager");
  const static QString LOGIN1_SESSION_INTERFACE = QStringLiteral("org.freedesktop.login1.Session");
  const static QString PROPERTY_INTERFACE = QStringLiteral("org.freedesktop.DBus.Properties");

  QString getSessionPath();
}
