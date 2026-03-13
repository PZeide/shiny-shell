#include "device.hpp"

#include "manager.hpp"
#include <algorithm>
#include <cmath>
#include <memory>
#include <optional>
#include <qdir.h>
#include <qelapsedtimer.h>
#include <qfileinfo.h>
#include <qfilesystemwatcher.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qproperty.h>
#include <qtimer.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Brightness {

Q_LOGGING_CATEGORY(logBrightnessDevice, "shiny.brightness.device", QtInfoMsg)

BrightnessDevice::BrightnessDevice(QObject* parent) : QObject(parent) {
    connect(this, &BrightnessDevice::deviceChanged, this, &BrightnessDevice::reloadDevice);
    connect(BrightnessManager::instance(), &BrightnessManager::deviceAdded, this,
            &BrightnessDevice::managerDeviceAdded);
    connect(BrightnessManager::instance(), &BrightnessManager::deviceRemoved, this,
            &BrightnessDevice::managerDeviceRemoved);
}

QBindable<QString> BrightnessDevice::bindableDevice() { return &b_device; }

bool BrightnessDevice::available() const { return m_controllerDir.has_value(); }

double BrightnessDevice::brightness() const {
    if (!m_controllerDir || m_maxBrightness <= 0)
        return 0.0;

    return static_cast<double>(m_committedBrightness) / m_maxBrightness;
}

double BrightnessDevice::realBrightness() const {
    if (!m_controllerDir || m_maxBrightness <= 0)
        return 0.0;

    return static_cast<double>(m_realBrightness) / m_maxBrightness;
}

void BrightnessDevice::commitBrightness(double value) {
    if (!m_controllerDir || m_maxBrightness <= 0)
        return;

    int raw = std::clamp(static_cast<int>(std::lround(value * m_maxBrightness)), 0, m_maxBrightness);

    if (raw == m_committedBrightness)
        return;

    QFile file(m_controllerDir->absoluteFilePath("brightness"));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qCWarning(logBrightnessDevice) << "Failed to write brightness:" << file.errorString();
        return;
    }

    file.write(QByteArray::number(raw));
    file.close();

    m_committedBrightness = raw;
    emit brightnessChanged();
}

void BrightnessDevice::commitBrightnessSmooth(double value) {
    if (!m_controllerDir || m_maxBrightness <= 0)
        return;

    int raw = std::clamp(static_cast<int>(std::lround(value * m_maxBrightness)), 0, m_maxBrightness);

    if (raw == m_committedBrightness)
        return;

    // Stop any existing smooth transition
    if (m_smoothTimer) {
        m_smoothTimer->stop();
        m_smoothTimer->deleteLater();
        m_smoothTimer = nullptr;
    }

    auto file = std::make_shared<QFile>(m_controllerDir->absoluteFilePath("brightness"));
    if (!file->open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qCWarning(logBrightnessDevice) << "Failed to write brightness:" << file->errorString();
        return;
    }

    m_smoothTimer = new QTimer(this);
    auto elapsed = std::make_shared<QElapsedTimer>();

    int start = readBrightness(*m_controllerDir);
    int delta = raw - start;

    connect(m_smoothTimer, &QTimer::timeout, this, [=, this]() {
        double progress = static_cast<double>(elapsed->elapsed()) / BRIGHTNESS_SMOOTH_MAX_TIME;
        int currentRaw = start + static_cast<int>(std::lround(delta * progress));

        file->seek(0);

        // If we are out of bounds or we have reached the target value, we stop the timer
        if (currentRaw > m_maxBrightness || progress >= 1.0) {
            file->write(QByteArray::number(raw));
            m_smoothTimer->stop();
            m_smoothTimer->deleteLater();
            m_smoothTimer = nullptr;
        } else {
            file->write(QByteArray::number(currentRaw));
        }

        file->flush();
    });

    connect(m_smoothTimer, &QTimer::destroyed, this, [file]() { file->close(); });

    elapsed->start();
    m_smoothTimer->start(BRIGHTNESS_SMOOTH_INTERVAL_MSECS);

    m_committedBrightness = raw;
    emit brightnessChanged();
}

void BrightnessDevice::reset() {
    if (!m_controllerDir) {
        return;
    }

    if (m_smoothTimer) {
        m_smoothTimer->stop();
        m_smoothTimer->deleteLater();
        m_smoothTimer = nullptr;
    }

    m_fsWatcher->deleteLater();
    m_fsWatcher = nullptr;

    m_controllerDir.reset();
    emit availableChanged();

    if (m_realBrightness != 0) {
        m_realBrightness = 0;
        emit realBrightnessChanged();
    }

    if (m_committedBrightness != 0) {
        m_committedBrightness = 0;
        emit brightnessChanged();
    }

    if (m_realBrightness != 0) {
        m_realBrightness = 0;
        emit realBrightnessChanged();
    }

    m_maxBrightness = 0;
}

bool BrightnessDevice::reloadDevice() {
    qCInfo(logBrightnessDevice) << "Updating brightness device with:" << *b_device;

    if ((*b_device).isEmpty()) {
        this->reset();
        return false;
    }

    auto controllerDir = BrightnessManager::instance()->device(b_device);
    if (!controllerDir) {
        qCWarning(logBrightnessDevice) << "Brightness device not found:" << *b_device;
        this->reset();
        return false;
    }

    int brightness = readBrightness(*controllerDir);
    int maxBrightness = readMaxBrightness(*controllerDir);

    if (brightness < 0 || maxBrightness < 0) {
        this->reset();
        return false;
    }

    QFileSystemWatcher* fsWatcher = new QFileSystemWatcher(this);
    QString brightnessPath = controllerDir->absoluteFilePath("brightness");
    if (!fsWatcher->addPath(brightnessPath)) {
        qCWarning(logBrightnessDevice) << "Failed to watch changes of path:" << brightnessPath;
        fsWatcher->deleteLater();
        this->reset();
        return false;
    }

    qCInfo(logBrightnessDevice) << "Linked to brightness device" << *b_device << "at path"
                                << controllerDir->absolutePath();
    connect(fsWatcher, &QFileSystemWatcher::fileChanged, this, &BrightnessDevice::brightnessFileChanged);
    m_controllerDir = *controllerDir;
    m_committedBrightness = brightness;
    m_realBrightness = brightness;
    m_maxBrightness = maxBrightness;
    m_fsWatcher = fsWatcher;
    emit availableChanged();
    emit brightnessChanged();
    emit realBrightnessChanged();
    return true;
}

void BrightnessDevice::managerDeviceAdded(const QString& name) {
    if (name == *b_device && !m_controllerDir) {
        qCInfo(logBrightnessDevice) << "Brightness device added to manager!";
        this->reloadDevice();
    }
}

void BrightnessDevice::managerDeviceRemoved(const QString& name) {
    if (name == *b_device && m_controllerDir) {
        qCWarning(logBrightnessDevice) << "Brightness device removed from manager!";
        this->reset();
    }
}

void BrightnessDevice::brightnessFileChanged() {
    if (!m_controllerDir.has_value()) {
        qCWarning(logBrightnessDevice) << "Detected file changes but no controller dir found!";
        return;
    }

    int brightness = readBrightness(*m_controllerDir);
    if (brightness >= 0) {
        if (brightness != m_realBrightness) {
            // Update real brightness
            m_realBrightness = brightness;
            emit realBrightnessChanged();
        }

        // Check if committed brightness is out of sync
        if (brightness != m_committedBrightness && (!m_smoothTimer || !m_smoothTimer->isActive())) {
            qCInfo(logBrightnessDevice) << "External brightness change detected. Resyncing committed brightness from"
                                        << m_committedBrightness << "to" << brightness;

            m_committedBrightness = brightness;
            emit brightnessChanged();
        }

        return;
    }

    if (!m_controllerDir->exists()) {
        qCWarning(logBrightnessDevice) << "Controller dir doesn't exists anymore!";
        this->reset();
    }
}

int BrightnessDevice::readBrightness(QDir& controllerDir) {
    QFile file(controllerDir.absoluteFilePath("brightness"));
    if (!file.open(QIODevice::ReadOnly)) {
        qCWarning(logBrightnessDevice) << "Failed to open brightness path:" << file.errorString();
        return -1;
    }

    bool ok = false;
    int brightness = file.readLine().toInt(&ok);
    return ok ? brightness : -1;
}

int BrightnessDevice::readMaxBrightness(QDir& controllerDir) {
    QFile file(controllerDir.absoluteFilePath("max_brightness"));
    if (!file.open(QIODevice::ReadOnly)) {
        qCWarning(logBrightnessDevice) << "Failed to open max brightness path:" << file.errorString();
        return -1;
    }

    bool ok = false;
    int maxBrightness = file.readLine().toInt(&ok);
    return ok ? maxBrightness : -1;
}

} // namespace Shiny::Brightness
