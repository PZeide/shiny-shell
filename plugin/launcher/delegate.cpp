#include "delegate.hpp"

#include "item.hpp"
#include "plugin.hpp"
#include <qlist.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qobjectdefs.h>
#include <qproperty.h>
#include <qqmllist.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Launcher {

Q_LOGGING_CATEGORY(logLauncher, "shiny.launcher", QtInfoMsg)

LauncherDelegate::LauncherDelegate(QObject* parent) : QObject(parent) {
    connect(this, &LauncherDelegate::inputChanged, this, &LauncherDelegate::update);
}

QBindable<QString> LauncherDelegate::bindableInput() { return &b_input; }

qsizetype LauncherDelegate::maxItems() const { return m_maxItems; }

void LauncherDelegate::setMaxItems(qsizetype maxItems) {
    if (m_maxItems == maxItems)
        return;

    if (maxItems < 1) {
        qCWarning(logLauncher) << "maxItems should be at least 1";
        return;
    }

    m_maxItems = maxItems;
    emit maxItemsChanged();
    update();
}

QQmlListProperty<LauncherPlugin> LauncherDelegate::plugins() {
    return QQmlListProperty<LauncherPlugin>(
        this, nullptr, &LauncherDelegate::pluginsAppend, &LauncherDelegate::pluginsCount, &LauncherDelegate::pluginsAt,
        &LauncherDelegate::pluginsClear, &LauncherDelegate::pluginsReplace, &LauncherDelegate::pluginsRemoveLast);
}

LauncherPlugin* LauncherDelegate::activePlugin() const { return m_activePlugin; }

LauncherItemListModel* LauncherDelegate::result() const { return m_resultModel; }

void LauncherDelegate::update() {
    LauncherPlugin* candidate = nullptr;
    for (const auto plugin : m_plugins) {
        if (plugin->canActivate(b_input) && (!candidate || plugin->priority() > candidate->priority())) {
            candidate = plugin;
        }
    }

    if (m_activePlugin != candidate) {
        if (m_activePlugin) {
            disconnect(m_activePlugin, &LauncherPlugin::filterResult, this, &LauncherDelegate::resultReceived);
        }

        m_activePlugin = candidate;
        emit activePluginChanged();

        connect(m_activePlugin, &LauncherPlugin::filterResult, this, &LauncherDelegate::resultReceived);
    }

    if (m_activePlugin) {
        m_activePlugin->filter(b_input, m_maxItems);
    }
}

void LauncherDelegate::resultReceived(QList<LauncherItem> items) {
    if (items.count() > m_maxItems)
        items.resize(m_maxItems);

    if (m_resultModel->items() != items) {
        m_resultModel->setItems(items);
        emit resultChanged();
    }
}

void LauncherDelegate::pluginsAppend(QQmlListProperty<LauncherPlugin>* property, LauncherPlugin* value) {
    LauncherDelegate* delegate = static_cast<LauncherDelegate*>(property->object);
    delegate->m_plugins.append(value);
    emit delegate->pluginsChanged();
    delegate->update();
}

qsizetype LauncherDelegate::pluginsCount(QQmlListProperty<LauncherPlugin>* property) {
    return static_cast<LauncherDelegate*>(property->object)->m_plugins.count();
}

LauncherPlugin* LauncherDelegate::pluginsAt(QQmlListProperty<LauncherPlugin>* property, qsizetype index) {
    return static_cast<LauncherDelegate*>(property->object)->m_plugins.at(index);
}

void LauncherDelegate::pluginsClear(QQmlListProperty<LauncherPlugin>* property) {
    LauncherDelegate* delegate = static_cast<LauncherDelegate*>(property->object);
    delegate->m_plugins.clear();
    emit delegate->pluginsChanged();
    delegate->update();
}

void LauncherDelegate::pluginsReplace(QQmlListProperty<LauncherPlugin>* property, qsizetype index,
                                      LauncherPlugin* value) {
    LauncherDelegate* delegate = static_cast<LauncherDelegate*>(property->object);
    delegate->m_plugins.replace(index, value);
    emit delegate->pluginsChanged();
    delegate->update();
}

void LauncherDelegate::pluginsRemoveLast(QQmlListProperty<LauncherPlugin>* property) {
    LauncherDelegate* delegate = static_cast<LauncherDelegate*>(property->object);
    delegate->m_plugins.removeLast();
    emit delegate->pluginsChanged();
    delegate->update();
}

}; // namespace Shiny::Launcher
