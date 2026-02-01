#pragma once

#include <qdbusabstractadaptor.h>
#include <qdbusmessage.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qpromise.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtdbusglobal.h>
#include <qtmetamacros.h>
#include <qvector.h>

namespace Shiny::Location {

Q_DECLARE_LOGGING_CATEGORY(logGeoClueAgent)

const uint MAX_ACCURACY_LEVEL = 8;

class GeoClueAgent;

class GeoClueAgentAdaptor : public QDBusAbstractAdaptor {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.GeoClue2.Agent")
    Q_CLASSINFO("D-Bus Introspection", ""
                                       "  <interface name=\"org.freedesktop.GeoClue2.Agent\">\n"
                                       "    <method name=\"AuthorizeApp\">\n"
                                       "      <arg name=\"desktop_id\" type=\"s\" direction=\"in\" />\n"
                                       "      <arg name=\"req_accuracy_level\" type=\"u\" direction=\"in\" />\n"
                                       "      <arg name=\"authorized\" type=\"b\" direction=\"out\" />\n"
                                       "      <arg name=\"allowed_accuracy_level\" type=\"u\" direction=\"out\" />\n"
                                       "    </method>\n"
                                       "    <property name=\"MaxAccuracyLevel\" type=\"u\" access=\"read\" />\n"
                                       "  </interface>\n"
                                       "")

    // clang-format off
    Q_PROPERTY(uint MaxAccuracyLevel READ maxAccuracyLevel CONSTANT)
    // clang-format on

public:
    explicit GeoClueAgentAdaptor(uint maxAccuracyLevel, GeoClueAgent* parent);

    uint maxAccuracyLevel() const;

public slots:
    void AuthorizeApp(const QString& desktopId, uint accuracyLevel, const QDBusMessage& message);

private:
    uint m_maxAccuracyLevel;
};

class GeoClueRequest : public QObject {
    Q_OBJECT
    QML_ANONYMOUS

    // clang-format off
    Q_PROPERTY(QString desktopId READ desktopId CONSTANT)
    Q_PROPERTY(uint accuracyLevel READ accuracyLevel CONSTANT)
    // clang-format on

public:
    explicit GeoClueRequest(const QString& desktopId, uint accuracyLevel,
                            std::shared_ptr<QPromise<bool>> authorizationPromise, QObject* parent = nullptr);

    QString desktopId() const;
    uint accuracyLevel() const;
    Q_INVOKABLE void authorize(bool authorized);

signals:
    void processed(bool authorized);

private:
    QString m_desktopId;
    uint m_accuracyLevel;
    std::shared_ptr<QPromise<bool>> m_authorizationPromise;
};

class GeoClueAgent : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QVector<Shiny::Location::GeoClueRequest*> requests READ requests NOTIFY requestsChanged)
    // clang-format on

public:
    explicit GeoClueAgent(QObject* parent = nullptr);

    QVector<GeoClueRequest*> requests() const;
    void handleRequest(const QString& desktopId, uint accuracyLevel,
                       std::shared_ptr<QPromise<bool>> authorizationPromise);

signals:
    void requestsChanged();
    void requestReceived(Shiny::Location::GeoClueRequest* request);

private:
    QVector<GeoClueRequest*> m_requests;
    GeoClueAgentAdaptor m_adaptor;
};

} // namespace Shiny::Location
