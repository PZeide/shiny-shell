#include "geoclue-agent.hpp"

#include <algorithm>
#include <memory>
#include <qdbusabstractadaptor.h>
#include <qdbusconnection.h>
#include <qdbusconnectioninterface.h>
#include <qdbusinterface.h>
#include <qdbusmessage.h>
#include <qdbusreply.h>
#include <qfileinfo.h>
#include <qfuture.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qpromise.h>

namespace Shiny::Location {

Q_LOGGING_CATEGORY(logGeoClueAgent, "shiny.location.geoclue-agent", QtInfoMsg)

GeoClueAgentAdaptor::GeoClueAgentAdaptor(uint maxAccuracyLevel, GeoClueAgent* parent)
    : QDBusAbstractAdaptor(parent), m_maxAccuracyLevel(maxAccuracyLevel) {}

uint GeoClueAgentAdaptor::maxAccuracyLevel() const { return m_maxAccuracyLevel; }

void GeoClueAgentAdaptor::AuthorizeApp(const QString& desktopId, uint accuracyLevel, const QDBusMessage& message) {
    message.setDelayedReply(true);

    auto promise = std::make_shared<QPromise<bool>>();

    promise->future().onFailed(this, []() { return false; }).then(this, [message, accuracyLevel](bool result) {
        QDBusMessage reply = message.createReply();
        reply << result << accuracyLevel;
        if (!QDBusConnection::sessionBus().send(reply))
            qCCritical(logGeoClueAgent) << "Failed to send reply to request!";
    });

    static_cast<GeoClueAgent*>(parent())->handleRequest(desktopId, accuracyLevel, promise);
}

GeoClueRequest::GeoClueRequest(const QString& desktopId, uint accuracyLevel,
                               std::shared_ptr<QPromise<bool>> authorizationPromise, QObject* parent)
    : QObject(parent), m_desktopId(desktopId), m_accuracyLevel(accuracyLevel),
      m_authorizationPromise(authorizationPromise) {}

QString GeoClueRequest::desktopId() const { return m_desktopId; }

uint GeoClueRequest::accuracyLevel() const { return m_accuracyLevel; }

void GeoClueRequest::authorize(bool authorized) {
    m_authorizationPromise->addResult(authorized);
    m_authorizationPromise->finish();
    emit processed(authorized);
}

GeoClueAgent::GeoClueAgent(QObject* parent) : QObject(parent), m_adaptor(MAX_ACCURACY_LEVEL, this) {
    QDBusConnection session = QDBusConnection::sessionBus();
    QDBusConnection system = QDBusConnection::systemBus();

    if (!system.interface()->startService("org.freedesktop.GeoClue2").isValid()) {
        qCCritical(logGeoClueAgent) << "Failed to start D-Bus service!";
        return;
    }

    if (!system.registerService("org.freedesktop.GeoClue2.Agent")) {
        qCCritical(logGeoClueAgent) << "Failed to register D-Bus service!";
        return;
    }

    if (!system.registerObject("/org/freedesktop/GeoClue2/Agent", "org.freedesktop.GeoClue2.Agent", this)) {
        qCCritical(logGeoClueAgent) << "Failed to register D-Bus object!";
        return;
    }

    QDBusInterface manager("org.freedesktop.GeoClue2", "/org/freedesktop/GeoClue2/Manager",
                           "org.freedesktop.GeoClue2.Manager", system);

    if (!manager.isValid()) {
        qCCritical(logGeoClueAgent) << "GeoClue Manager not found!" << manager.lastError();
        return;
    }

    QDBusPendingCall pendingCall = manager.asyncCall("AddAgent", "shiny-shell");
    QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(pendingCall, this);
    connect(watcher, &QDBusPendingCallWatcher::finished, this, [](QDBusPendingCallWatcher* self) {
        QDBusReply<void> reply = *self;
        if (reply.isValid()) {
            qCInfo(logGeoClueAgent) << "Successfully registered as a GeoClue Agent.";
        } else {
            qCCritical(logGeoClueAgent) << "AddAgent failed:" << reply.error().message();
        }

        self->deleteLater();
    });
}

QVector<GeoClueRequest*> GeoClueAgent::requests() const { return m_requests; }

void GeoClueAgent::handleRequest(const QString& desktopId, uint accuracyLevel,
                                 std::shared_ptr<QPromise<bool>> authorizationPromise) {
    qCInfo(logGeoClueAgent) << "Received authorization request from" << desktopId << "with accuracy" << accuracyLevel;
    auto request = new GeoClueRequest(desktopId, accuracyLevel, authorizationPromise, this);

    connect(request, &GeoClueRequest::processed, this, [this, request]() {
        auto end = std::remove(m_requests.begin(), m_requests.end(), request);
        if (end == m_requests.end()) {
            qCWarning(logGeoClueAgent) << "Request for" << request->desktopId() << "has already been processed!";
        } else {
            m_requests.erase(end, m_requests.end());
            emit requestsChanged();
        }

        request->deleteLater();
    });

    m_requests.push_back(request);
    emit requestsChanged();
    emit requestReceived(request);
}

} // namespace Shiny::Location
