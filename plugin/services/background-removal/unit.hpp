#pragma once

#include <QDir>
#include <QFileInfo>
#include <QObject>
#include <QProcess>
#include <QString>
#include <QUrl>
#include <QtQmlIntegration>
#include <memory>

namespace Shiny::Services::BackgroundRemoval {
  class BackgroundRemovalUnit : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString cacheDirectory READ cacheDirectory WRITE setCacheDirectory NOTIFY cacheDirectoryChanged)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool processing READ processing NOTIFY processingChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

  public:
    explicit BackgroundRemovalUnit(QObject* parent = nullptr);

    [[nodiscard]] QString cacheDirectory() const;
    void setCacheDirectory(QString cacheDirectory);

    [[nodiscard]] QString source() const;
    void setSource(QString source);

    [[nodiscard]] bool processing() const;

    [[nodiscard]] bool available() const;

    [[nodiscard]] QString result() const;

  public slots:
    Q_INVOKABLE void start(bool ignoreCache = false);

  private slots:
    void processError(QProcess::ProcessError error);
    void processFinished(int exitCode, QProcess::ExitStatus exitStatus);

  signals:
    void cacheDirectoryChanged();
    void sourceChanged();
    void processingChanged();
    void availableChanged();
    void resultChanged();

  private:
    QDir m_cacheDirectory = QDir::temp();
    std::unique_ptr<QFileInfo> m_source;
    bool m_processing = false;
    std::unique_ptr<QProcess> m_runningProcess;
    bool m_available = false;
    std::unique_ptr<QFileInfo> m_result;
  };
} // namespace Shiny::Services::BackgroundRemoval
