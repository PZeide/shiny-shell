#pragma once

#include <qdbusabstractadaptor.h>
#include <qdbusmessage.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qpromise.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>

namespace Shiny::Location {

Q_DECLARE_LOGGING_CATEGORY(logGeoclueAgent)

class GeoclueAgentAdaptor : QDBusAbstractAdaptor {
  Q_OBJECT
  Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Geoclue2.Agent")

public:
  GeoclueAgentAdaptor(QObject *parent = nullptr) : QDBusAbstractAdaptor(parent) {}

signals:
  void authorizeApp(const QString &desktopId, uint accuracyLevel, QPromise<bool> resultPromise);

private slots:
  void AuthorizeApp(const QString &desktop_id, uint accuracy_level, const QDBusMessage &message);
};

} // namespace Shiny::Location
