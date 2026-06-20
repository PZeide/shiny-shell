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
#include <qvariant.h>
#include <sys/types.h>

namespace Shiny::Screenshot {

Q_LOGGING_CATEGORY(logScreenshot, "shiny.screenshot", QtInfoMsg)

ScreenshotRequest::ScreenshotRequest(QObject* parent) : QObject(parent) {}

bool ScreenshotRequest::finished() const { return m_finished; }

bool ScreenshotRequest::failed() const { return m_failed; }

uint ScreenshotRequest::response() const { return m_response; }

const QString ScreenshotRequest::uri() const { return m_uri; }

const QString ScreenshotRequest::errorMessage() const { return m_errorMessage; }

void ScreenshotRequest::setError(const QString& message) { finish(2, QString(), message); }

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

    auto reply = portal.Screenshot(QString(), options);
    auto watcher = new QDBusPendingCallWatcher(reply, request);
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, request, [request, watcher, bus]() mutable {
        QDBusPendingReply<QDBusObjectPath> result = *watcher;
        watcher->deleteLater();

        if (result.isError()) {
            request->setError(result.error().message());
            return;
        }

        bool connected = bus.connect(PORTAL_SERVICE, result.value().path(), PORTAL_REQUEST_INTERFACE, "Response",
                                     request, SLOT(handleResponse(uint, QVariantMap)));
        if (!connected) {
            request->setError("Could not connect to screenshot portal response signal.");
        }
    });

    return request;
}

} // namespace Shiny::Screenshot
