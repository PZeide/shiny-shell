#include "geoclue-agent.hpp"

#include <qdbusconnection.h>
#include <qdbusmessage.h>
#include <qfuture.h>
#include <qlogging.h>
#include <qloggingcategory.h>

namespace Shiny::Location {

Q_LOGGING_CATEGORY(logGeoclueAgent, "shiny.location.geoclue-agent", QtInfoMsg)

void GeoclueAgentAdaptor::AuthorizeApp(const QString &desktop_id, uint accuracy_level, const QDBusMessage &message) {
  message.setDelayedReply(true);
  QDBusMessage reply = message.createReply();

  QPromise<bool> resultPromise;
  QFuture<bool> futureResult = resultPromise.future();

  futureResult.then(this, [&reply, accuracy_level](bool result) {
    reply << result << accuracy_level;

    if (!QDBusConnection::sessionBus().send(reply)) {
      qCCritical(logGeoclueAgent) << "Failed to send reply to request!";
    }
  });

  futureResult.onFailed(this, [&reply, accuracy_level]() {
    qCWarning(logGeoclueAgent) << "App authorization promise failed!";
    reply << false << accuracy_level;

    if (!QDBusConnection::sessionBus().send(reply)) {
      qCCritical(logGeoclueAgent) << "Failed to send reply to request!";
    }
  });

  emit authorizeApp(desktop_id, accuracy_level, std::move(resultPromise));
}

} // namespace Shiny::Location
