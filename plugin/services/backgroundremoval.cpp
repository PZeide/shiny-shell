#include "backgroundremoval.hpp"
#include <qbytearray.h>
#include <qcontainerfwd.h>
#include <qcryptographichash.h>
#include <qdir.h>
#include <qfile.h>
#include <qlogging.h>

namespace Shiny::Services {
  Q_LOGGING_CATEGORY(logBackgroundRemoval, "shiny.services.backgroundremoval", QtInfoMsg)

  BackgroundRemovalUnit::BackgroundRemovalUnit(QObject* parent) : QObject(parent) {}

  QString BackgroundRemovalUnit::cacheDirectory() const {
    return m_cacheDirectory.path();
  }

  void BackgroundRemovalUnit::setCacheDirectory(QString cacheDirectory) {
    if (m_cacheDirectory.path() == cacheDirectory)
      return;

    QFileInfo newCacheDirectory(cacheDirectory);
    if (!newCacheDirectory.isDir() || !newCacheDirectory.isWritable()) {
      qCWarning(logBackgroundRemoval)
        << "Cache directory is either missing, not a directory or is not writable";
      return;
    }

    m_cacheDirectory = QDir(newCacheDirectory.filePath());
    emit cacheDirectoryChanged();
  }

  QString BackgroundRemovalUnit::source() const {
    return m_source ? m_source->filePath() : "";
  }

  void BackgroundRemovalUnit::setSource(QString source) {
    if ((!m_source && source.isEmpty()) || (m_source && m_source->filePath() == source))
      return;

    // Treat empty string as "null"
    if (source.isEmpty()) {
      m_source = nullptr;
      emit sourceChanged();
      m_result = nullptr;
      emit resultChanged();

      if (m_processing) {
        m_processing = false;
        emit processingChanged();
        m_runningProcess = nullptr;
      }

      if (m_available) {
        m_available = false;
        emit availableChanged();
      }

      return;
    }

    QFileInfo newSource(source);
    if (!newSource.isFile() || !newSource.isReadable()) {
      qCWarning(logBackgroundRemoval) << "Source is either missing, not a file or is not readable";
      return;
    }

    QFile newSourceFile(newSource.filePath());
    if (!newSourceFile.open(QIODevice::ReadOnly))
      return;

    QByteArray hash = QCryptographicHash::hash(newSourceFile.readAll(), QCryptographicHash::Sha256);
    QString resultFileName = QString("shell_bru-%1.png").arg(hash.toHex());

    m_source = std::make_unique<QFileInfo>(newSourceFile);
    emit sourceChanged();

    m_result = std::make_unique<QFileInfo>(m_cacheDirectory, resultFileName);
    emit resultChanged();

    if (m_processing) {
      m_processing = false;
      emit processingChanged();
      m_runningProcess = nullptr;
    }

    if (m_available) {
      m_available = false;
      emit availableChanged();
    }

    start();
  }

  bool BackgroundRemovalUnit::processing() const {
    return m_processing;
  }

  bool BackgroundRemovalUnit::available() const {
    return m_available;
  }

  QString BackgroundRemovalUnit::result() const {
    return m_result ? m_result->filePath() : "";
  }

  void BackgroundRemovalUnit::start(bool ignoreCache) {
    if (!m_source || !m_result) {
      qCWarning(logBackgroundRemoval) << "Cannot process because source is missing";
      return;
    }

    if (m_processing) {
      m_runningProcess = nullptr;
      m_processing = false;
      emit processingChanged();
    }

    if (!ignoreCache && m_result->exists()) {
      m_available = true;
      emit availableChanged();
      return;
    }

    m_runningProcess = std::make_unique<QProcess>();

    connect(
      m_runningProcess.get(),
      &QProcess::finished,
      this,
      &BackgroundRemovalUnit::processFinished
    );

    connect(
      m_runningProcess.get(),
      &QProcess::errorOccurred,
      this,
      &BackgroundRemovalUnit::processError
    );

    QStringList arguments;
    arguments << "i" << "-m" << "birefnet-general" << m_source->absoluteFilePath()
              << m_result->absoluteFilePath();
    m_runningProcess->start("rembg", arguments);

    m_processing = true;
    emit processingChanged();
  }

  void BackgroundRemovalUnit::processError(QProcess::ProcessError) {
    if (!m_processing)
      return;

    qCWarning(logBackgroundRemoval)
      << "The background removal process failed:" << m_runningProcess->errorString();

    m_runningProcess = nullptr;
    m_processing = false;
    emit processingChanged();
  }

  void BackgroundRemovalUnit::processFinished(int, QProcess::ExitStatus exitStatus) {
    if (!m_processing)
      return;

    m_runningProcess = nullptr;
    m_processing = false;
    emit processingChanged();

    if (exitStatus == QProcess::ExitStatus::CrashExit) {
      qCWarning(logBackgroundRemoval)
        << "The background removal process failed:" << m_runningProcess->errorString();
      return;
    }

    qCInfo(logBackgroundRemoval) << "Processing of source image finished";
    m_available = true;
    emit availableChanged();
  }
}
