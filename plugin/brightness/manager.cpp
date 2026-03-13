#include "manager.hpp"

#include <optional>
#include <qdir.h>
#include <qfileinfo.h>
#include <qfilesystemwatcher.h>
#include <qlist.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qmap.h>
#include <qobject.h>
#include <qset.h>
#include <qtmetamacros.h>

namespace Shiny::Brightness {

Q_LOGGING_CATEGORY(logBrightness, "shiny.brightness", QtInfoMsg)

BrightnessManager* BrightnessManager::instance() {
    static BrightnessManager* instance = new BrightnessManager();
    return instance;
}

const QMap<QString, QDir>& BrightnessManager::devices() const { return m_devices; }

std::optional<QDir> BrightnessManager::device(const QString& name) const {
    auto it = m_devices.constFind(name);
    if (it == m_devices.cend())
        return std::nullopt;

    return it.value();
}

void BrightnessManager::sysfsChanged() {
    bool changed = false;
    QSet<QString> tracked;

    for (QFileInfo& info : SYSFS_BACKLIGHT.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QString path = info.canonicalFilePath();
        QDir parentDir = QFileInfo(path).dir();
        QString deviceName = parentDir.dirName().section("-", 1);

        if (deviceName.isEmpty()) {
            qCWarning(logBrightness) << "Invalid brightness device found at" << path;
            continue;
        }

        tracked.insert(deviceName);

        if (m_devices.contains(deviceName)) {
            continue;
        }

        qCDebug(logBrightness) << "Added device" << deviceName << "at path" << path;
        m_devices.insert(deviceName, QDir(path));
        emit deviceAdded(deviceName);
        changed = true;
    }

    for (auto it = m_devices.begin(); it != m_devices.end();) {
        if (!tracked.contains(it.key())) {
            qCDebug(logBrightness) << "Removed device" << it.key();
            it = m_devices.erase(it);
            emit deviceRemoved(it.key());
            changed = true;
        } else {
            ++it;
        }
    }

    if (changed) {
        emit devicesChanged();
    }
}

BrightnessManager::BrightnessManager(QObject* parent) : QObject(parent) {
    connect(m_fsWatcher, &QFileSystemWatcher::directoryChanged, this, &BrightnessManager::sysfsChanged);

    if (!m_fsWatcher->addPath(SYSFS_BACKLIGHT.absolutePath())) {
        qCWarning(logBrightness) << "Failed to watch sysfs changes, brightness won't work!";
        return;
    }

    // First initial sysfs update
    sysfsChanged();
}

} // namespace Shiny::Brightness
