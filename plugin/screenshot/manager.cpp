#include "manager.hpp"

#include "dbus_screenshot.h"
#include <qcontainerfwd.h>
#include <qdbusconnection.h>
#include <qdbusconnectioninterface.h>
#include <qdbusextratypes.h>
#include <qdbuspendingcall.h>
#include <qdbuspendingreply.h>
#include <qdir.h>
#include <qhashfunctions.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qtmetamacros.h>
#include <qurl.h>
#include <quuid.h>
#include <qvariant.h>
#include <sys/types.h>

namespace Shiny::Screenshot {

Q_LOGGING_CATEGORY(logScreenshot, "shiny.screenshot", QtInfoMsg)

ScreenshotRequest::ScreenshotRequest(QObject* parent) : QObject(parent) {}

bool ScreenshotRequest::finished() const { return m_finished; }

bool ScreenshotRequest::failed() const { return m_failed; }

uint ScreenshotRequest::response() const { return m_response; }

const QString ScreenshotRequest::uri() const { return m_uri; }

const QString ScreenshotRequest::path() const { return QUrl(m_uri).toLocalFile(); }

const QString ScreenshotRequest::errorMessage() const { return m_errorMessage; }

void ScreenshotRequest::setError(const QString& message) { finish(2, QString(), message); }

void ScreenshotRequest::cancel() {
    if (m_finished || m_requestPath.isEmpty()) {
        return;
    }

    auto bus = QDBusConnection::sessionBus();
    bus.asyncCall(QDBusMessage::createMethodCall(PORTAL_SERVICE, m_requestPath, PORTAL_REQUEST_INTERFACE, "Close"));
    bus.disconnect(PORTAL_SERVICE, m_requestPath, PORTAL_REQUEST_INTERFACE, "Response", this,
                   SLOT(handleResponse(uint, QVariantMap)));
    finish(1, QString(), QString());
}

void ScreenshotRequest::setRequestPath(const QString& requestPath) { m_requestPath = requestPath; }

void ScreenshotRequest::handleResponse(uint response, QVariantMap results) {
    QString uri;
    if (results.contains("uri")) {
        uri = results.value("uri").toString();
    }

    if (response == 0 && uri.isEmpty()) {
        finish(response, uri, "Screenshot portal returned no URI.");
        return;
    }

    finish(response, uri, QString());
}

void ScreenshotRequest::finish(uint response, const QString& uri, const QString& errorMessage) {
    if (m_finished) {
        return;
    }

    m_finished = true;
    m_response = response;
    m_uri = uri;
    m_errorMessage = errorMessage;
    m_failed = response != 0 || !errorMessage.isEmpty();

    emit finishedChanged();
    emit responseChanged();
    emit uriChanged();
    emit errorMessageChanged();
    emit failedChanged();

    if (!errorMessage.isEmpty()) {
        qCWarning(logScreenshot) << "Screenshot failed:" << errorMessage;
        emit failedWithError(errorMessage);
    } else if (response == 1) {
        emit cancelled();
    } else if (response != 0) {
        emit failedWithError(QStringLiteral("Screenshot portal returned response %1.").arg(response));
    } else {
        emit completed(uri);
    }
}

ScreenshotManager::ScreenshotManager(QObject* parent) : QObject(parent) {}

ScreenshotRequest* ScreenshotManager::screenshot(bool interactive) {
    auto request = new ScreenshotRequest(this);
    auto bus = QDBusConnection::sessionBus();
    if (!bus.isConnected()) {
        request->setError("Could not connect to session DBus.");
        return request;
    }

    if (!bus.interface()->startService(PORTAL_SERVICE).isValid()) {
        request->setError("Failed to start xdg-desktop-portal.");
        return request;
    }

    DBusPortalScreenshot portal(PORTAL_SERVICE, PORTAL_PATH, bus, this);
    if (!portal.isValid()) {
        request->setError("Could not connect to xdg-desktop-portal screenshot interface.");
        return request;
    }

    QVariantMap options;
    options.insert("interactive", interactive);

    const auto handleToken = QStringLiteral("shiny_screenshot_%1").arg(QUuid::createUuid().toString(QUuid::Id128));
    options.insert("handle_token", handleToken);

    auto senderName = bus.baseService();
    if (senderName.startsWith(':')) {
        senderName.remove(0, 1);
    }
    senderName.replace('.', '_');

    const auto requestPath =
        QStringLiteral("/org/freedesktop/portal/desktop/request/%1/%2").arg(senderName, handleToken);
    request->setRequestPath(requestPath);
    const bool connected = bus.connect(PORTAL_SERVICE, requestPath, PORTAL_REQUEST_INTERFACE, "Response", request,
                                       SLOT(handleResponse(uint, QVariantMap)));
    if (!connected) {
        request->setError("Could not connect to screenshot portal response signal.");
        return request;
    }

    auto reply = portal.Screenshot(QString(), options);
    auto watcher = new QDBusPendingCallWatcher(reply, request);
    QObject::connect(
        watcher, &QDBusPendingCallWatcher::finished, request, [request, watcher, bus, requestPath]() mutable {
            QDBusPendingReply<QDBusObjectPath> result = *watcher;
            watcher->deleteLater();

            if (result.isError()) {
                bus.disconnect(PORTAL_SERVICE, requestPath, PORTAL_REQUEST_INTERFACE, "Response", request,
                               SLOT(handleResponse(uint, QVariantMap)));
                request->setError(result.error().message());
                return;
            }

            if (result.value().path() != requestPath) {
                bus.disconnect(PORTAL_SERVICE, requestPath, PORTAL_REQUEST_INTERFACE, "Response", request,
                               SLOT(handleResponse(uint, QVariantMap)));
                request->setError(QStringLiteral("Screenshot portal returned an unexpected request path: %1")
                                      .arg(result.value().path()));
            }
        });

    return request;
}
} // namespace Shiny::Screenshot
