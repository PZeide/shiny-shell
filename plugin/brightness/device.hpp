#pragma once

#include <optional>
#include <qcontainerfwd.h>
#include <qdir.h>
#include <qfilesystemwatcher.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qtimer.h>
#include <qtmetamacros.h>

namespace Shiny::Brightness {

Q_DECLARE_LOGGING_CATEGORY(logBrightnessDevice)

constexpr int BRIGHTNESS_SMOOTH_INTERVAL_MSECS = 20;
constexpr int BRIGHTNESS_SMOOTH_MAX_TIME = 600;

class BrightnessDevice : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QString device READ default WRITE default NOTIFY deviceChanged BINDABLE bindableDevice REQUIRED)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(double brightness READ brightness NOTIFY brightnessChanged)
    Q_PROPERTY(double realBrightness READ realBrightness NOTIFY realBrightnessChanged)
    // clang-format on

public:
    explicit BrightnessDevice(QObject* parent = nullptr);

    QBindable<QString> bindableDevice();
    bool available() const;
    double brightness() const;
    double realBrightness() const;

    Q_INVOKABLE void commitBrightness(double brightness);
    Q_INVOKABLE void commitBrightnessSmooth(double brightness);

signals:
    void deviceChanged();
    void brightnessChanged();
    void realBrightnessChanged();
    void availableChanged();

private slots:
    void reset();
    bool reloadDevice();
    void managerDeviceAdded(const QString& name);
    void managerDeviceRemoved(const QString& name);
    void brightnessFileChanged();

private:
    std::optional<QDir> m_controllerDir;
    int m_committedBrightness = 0;
    int m_realBrightness = 0;
    int m_maxBrightness = 0;
    QFileSystemWatcher* m_fsWatcher = nullptr;
    QTimer* m_smoothTimer = nullptr;

    // clang-format off
    Q_OBJECT_BINDABLE_PROPERTY(BrightnessDevice, QString, b_device, &BrightnessDevice::deviceChanged)
    // clang-format on

    static int readBrightness(QDir& controllerDir);
    static int readMaxBrightness(QDir& controllerDir);
};

} // namespace Shiny::Brightness
