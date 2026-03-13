#pragma once

#include <optional>
#include <qdir.h>
#include <qfilesystemwatcher.h>
#include <qlist.h>
#include <qloggingcategory.h>
#include <qmap.h>
#include <qobject.h>
#include <qtmetamacros.h>

namespace Shiny::Brightness {

Q_DECLARE_LOGGING_CATEGORY(logBrightness)

const QDir SYSFS_BACKLIGHT = QDir("/sys/class/backlight/");

class BrightnessManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(const QMap<QString, QDir> devices READ devices NOTIFY devicesChanged)

public:
    static BrightnessManager* instance();

    const QMap<QString, QDir>& devices() const;
    Q_INVOKABLE std::optional<QDir> device(const QString& name) const;

signals:
    void devicesChanged();
    void deviceAdded(const QString& name);
    void deviceRemoved(const QString& name);

private slots:
    void sysfsChanged();

private:
    explicit BrightnessManager(QObject* parent = nullptr);

    QFileSystemWatcher* m_fsWatcher = new QFileSystemWatcher(this);
    QMap<QString, QDir> m_devices;
};

} // namespace Shiny::Brightness
