#include "brightness.hpp"
#include <algorithm>
#include <cmath>
#include <optional>
#include <qelapsedtimer.h>
#include <qlogging.h>
#include <qnumeric.h>
#include <qobject.h>
#include <qstringliteral.h>
#include <qtimer.h>
#include <qtypes.h>

namespace Shiny::Services {
  Q_LOGGING_CATEGORY(logBrightness, "shiny.services.brightness", QtInfoMsg)

  BrightnessController::BrightnessController(QObject* parent) : QObject(parent) {
    connect(
      &m_brightnessWatcher,
      &QFileSystemWatcher::fileChanged,
      this,
      &BrightnessController::brightnessFileChanged
    );
  }

  bool BrightnessController::available() const {
    return m_controllerDir.has_value();
  }

  QString BrightnessController::controller() const {
    return m_controllerDir ? m_controllerDir->dirName() : "";
  }

  void BrightnessController::setController(QString controller) {
    if (m_controllerDir && m_controllerDir->dirName() == controller) {
      return;
    }

    QDir controllerDir;
    if (controller.isEmpty()) {
      auto controllerDirOpt = preferredController();
      if (!controllerDirOpt) {
        qCWarning(logBrightness) << "Failed to find the preferred controller";
        return;
      }

      controllerDir = *controllerDirOpt;
    } else {
      controllerDir = QDir(SYS_BACKLIGHT + controller);
      if (!controllerDir.exists()) {
        qCWarning(logBrightness) << "Controller not found at path:" << controllerDir.absolutePath();
        return;
      }
    }

    setupController(controllerDir);
  }

  qreal BrightnessController::value() const {
    return m_maxRawValue > 0 ? m_rawValue / static_cast<qreal>(m_maxRawValue) : 0;
  }

  void BrightnessController::setValue(qreal value) {
    if (!m_controllerDir) {
      qCWarning(logBrightness) << "Cannot set brightness value because controller is missing";
      return;
    }

    int rawValue =
      std::clamp(static_cast<int>(std::lround(value * m_maxRawValue)), 0, m_maxRawValue);

    if (m_rawValue == rawValue)
      return;

    QFile file(m_controllerDir->absoluteFilePath("brightness"));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
      qCWarning(logBrightness) << "Cannot open brightness control file";
      return;
    }

    if (m_smoothTimer) {
      m_smoothTimer->stop();
      m_smoothTimer = nullptr;
    }

    file.write(QByteArray::number(rawValue));
    file.close();
  }

  void BrightnessController::setValueSmooth(qreal value, int durationMsecs) {
    if (!m_controllerDir) {
      qCWarning(logBrightness) << "Cannot set brightness value because controller is missing";
      return;
    }

    if (durationMsecs < 0) {
      qCWarning(logBrightness) << "Invalid brightness smooth change duration";
      return;
    }

    int rawValue =
      std::clamp(static_cast<int>(std::lround(value * m_maxRawValue)), 0, m_maxRawValue);

    if (m_rawValue == rawValue)
      return;

    auto file = std::make_shared<QFile>(m_controllerDir->absoluteFilePath("brightness"));
    if (!file->open(QIODevice::WriteOnly | QIODevice::Truncate)) {
      qCWarning(logBrightness) << "Cannot open brightness control file";
      return;
    }

    if (m_smoothTimer) {
      m_smoothTimer->stop();
      m_smoothTimer = nullptr;
    }

    m_smoothTimer = std::make_unique<QTimer>();
    auto elapsed = std::make_shared<QElapsedTimer>();

    int start = m_rawValue;
    int delta = rawValue - start;

    connect(m_smoothTimer.get(), &QTimer::timeout, this, [=, this]() mutable {
      qint64 time = elapsed->elapsed();
      qreal progress = static_cast<qreal>(time) / durationMsecs;
      int currentRawValue = static_cast<int>(std::lround(start + delta * progress));

      file->seek(0);

      // If we are out of bounds or we have reached the target value, we stop the timer
      if (currentRawValue > m_maxRawValue || progress >= 1.0) {
        file->write(QByteArray::number(rawValue));
        m_smoothTimer->stop();
        m_smoothTimer = nullptr;
      } else {
        file->write(QByteArray::number(currentRawValue));
      }

      file->flush();
    });

    connect(m_smoothTimer.get(), &QTimer::destroyed, this, [=]() mutable { file->close(); });

    elapsed->start();
    m_smoothTimer->start(BRIGHTNESS_SMOOTH_INTERVAL_MSECS);
  }

  qreal BrightnessController::naturalValue() const {
    return std::pow(value(), 1.0 / BRIGHTNESS_GAMMA);
  }

  void BrightnessController::setNaturalValue(qreal naturalValue) {
    setValue(std::pow(naturalValue, BRIGHTNESS_GAMMA));
  }

  void BrightnessController::setNaturalValueSmooth(qreal naturalValue, int durationMsecs) {
    setValueSmooth(std::pow(naturalValue, BRIGHTNESS_GAMMA), durationMsecs);
  }

  void BrightnessController::brightnessFileChanged() {
    if (!m_controllerDir) {
      qCWarning(logBrightness) << "Detected file changes but no controller dir found";
      return;
    }

    auto brightness = readBrightness(*m_controllerDir);
    if (brightness) {
      if (m_rawValue == brightness)
        return;

      m_rawValue = *brightness;
      emit valueChanged();
      return;
    }

    qCWarning(logBrightness) << "Failed to read brightness change";
    if (!m_controllerDir->exists()) {
      qCWarning(logBrightness) << "Selected controller doesn't exist, falling back to preferred";

      auto controllerDirOpt = preferredController();
      if (!controllerDirOpt) {
        qCWarning(logBrightness) << "Failed to find the preferred controller";
        reset();
        return;
      }

      if (!setupController(*controllerDirOpt)) {
        qCWarning(logBrightness) << "Failed to fallback to preferred controller";
        reset();
        return;
      }
    }
  }

  bool BrightnessController::setupController(QDir controllerDir) {
    if (!controllerDir.exists()) {
      qCWarning(logBrightness) << "Failed to change controller, missing control directory";
      return false;
    }

    std::optional<int> maxBrightness = readMaxBrightness(controllerDir);
    std::optional<int> brightness = readBrightness(controllerDir);

    if (!maxBrightness || !brightness) {
      qCWarning(logBrightness) << "Failed to change controller, cannot read default values";
      return false;
    }

    if (!m_brightnessWatcher.files().isEmpty()) {
      m_brightnessWatcher.removePaths(m_brightnessWatcher.files());
    }

    if (!m_brightnessWatcher.addPath(controllerDir.absoluteFilePath("brightness"))) {
      qCWarning(logBrightness) << "Failed to add new controller path to watcher";
      return false;
    }

    if (m_smoothTimer) {
      m_smoothTimer->stop();
      m_smoothTimer = nullptr;
    }

    m_controllerDir = controllerDir;
    emit controllerChanged();
    emit availableChanged();

    m_rawValue = *brightness;
    m_maxRawValue = *maxBrightness;
    emit valueChanged();

    qCInfo(logBrightness) << "Brightness controller set to" << controllerDir.absolutePath();
    return true;
  }

  void BrightnessController::reset() {
    if (!m_brightnessWatcher.files().isEmpty()) {
      m_brightnessWatcher.removePaths(m_brightnessWatcher.files());
    }

    if (m_smoothTimer) {
      m_smoothTimer->stop();
      m_smoothTimer = nullptr;
    }

    m_controllerDir = std::nullopt;
    emit controllerChanged();
    emit availableChanged();

    m_rawValue = 0;
    m_maxRawValue = 0;
    emit valueChanged();

    qCInfo(logBrightness) << "Brightness controller reset";
  }

  std::optional<int> BrightnessController::readBrightness(QDir& controllerDir) {
    QFile file(controllerDir.absoluteFilePath("brightness"));
    if (!file.open(QIODevice::ReadOnly))
      return std::nullopt;

    bool ok = false;
    int brightness = file.readLine().toInt(&ok);
    return ok ? std::make_optional(brightness) : std::nullopt;
  }

  std::optional<int> BrightnessController::readMaxBrightness(QDir& controllerDir) {
    QFile file(controllerDir.absoluteFilePath("max_brightness"));
    if (!file.open(QIODevice::ReadOnly))
      return std::nullopt;

    bool ok = false;
    int maxBrightness = file.readLine().toInt(&ok);
    return ok ? std::make_optional(maxBrightness) : std::nullopt;
  }

  std::optional<QDir> BrightnessController::preferredController() {
    QDir controllers(SYS_BACKLIGHT);
    if (!controllers.exists() || !controllers.isReadable()) {
      qCWarning(logBrightness) << "Failed to list all backlight controllers";
      return std::nullopt;
    }

    std::optional<QDir> preferredController = std::nullopt;
    int highestMaxBrightness = 0;

    for (QFileInfo& controllerInfo : controllers.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot)) {
      if (!controllerInfo.isDir())
        continue;

      QDir controllerDir(controllerInfo.absoluteFilePath());
      std::optional<int> maxBrightness = readMaxBrightness(controllerDir);
      if (!maxBrightness) {
        qCWarning(logBrightness) << "Failed to read max brightness of controller" << controllerDir;
        continue;
      }

      if (maxBrightness > highestMaxBrightness) {
        highestMaxBrightness = *maxBrightness;
        preferredController = QDir(controllerInfo.absoluteFilePath());
      }
    }

    return preferredController;
  }
}
