#pragma once

#include <qcontainerfwd.h>
#include <qdir.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qvariant.h>
#include <sys/types.h>

namespace Shiny::Screenshot {

Q_DECLARE_LOGGING_CATEGORY(logScreenshot)

const QString PORTAL_SERVICE = QStringLiteral("org.freedesktop.portal.Desktop");
const QString PORTAL_PATH = QStringLiteral("/org/freedesktop/portal/desktop");
const QString PORTAL_REQUEST_INTERFACE = QStringLiteral("org.freedesktop.portal.Request");

class ScreenshotRequest : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("ScreenshotRequest is returned by ScreenshotManager")

    // clang-format off
    Q_PROPERTY(bool finished READ finished NOTIFY finishedChanged)
    Q_PROPERTY(bool failed READ failed NOTIFY failedChanged)
    Q_PROPERTY(uint response READ response NOTIFY responseChanged)
    Q_PROPERTY(QString uri READ uri NOTIFY uriChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    // clang-format on

public:
    explicit ScreenshotRequest(QObject* parent = nullptr);

    bool finished() const;
    bool failed() const;
    uint response() const;
    const QString uri() const;
    const QString errorMessage() const;

    void setError(const QString& message);

signals:
    void finishedChanged();
    void failedChanged();
    void responseChanged();
    void uriChanged();
    void errorMessageChanged();

    void completed(const QString& uri);
    void cancelled();
    void failedWithError(const QString& message);

private slots:
    void handleResponse(uint response, QVariantMap results);

private:
    void finish(uint response, const QString& uri, const QString& errorMessage);

    bool m_finished = false;
    bool m_failed = false;
    uint m_response = 0;
    QString m_uri;
    QString m_errorMessage;
};

class ScreenshotManager : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(ScreenshotManager)
    QML_SINGLETON

public:
    explicit ScreenshotManager(QObject* parent = nullptr);

    Q_INVOKABLE Shiny::Screenshot::ScreenshotRequest* screenshot(bool interactive = true);
};

} // namespace Shiny::Screenshot
