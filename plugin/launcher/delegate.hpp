#pragma once

#include "item.hpp"
#include "plugin.hpp"
#include <limits>
#include <qlist.h>
#include <qloggingcategory.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qqmllist.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Launcher {
  Q_DECLARE_LOGGING_CATEGORY(logLauncher)

  class LauncherDelegate : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QString input READ input WRITE setInput NOTIFY inputChanged REQUIRED)
    Q_PROPERTY(qsizetype maxItems READ maxItems WRITE setMaxItems NOTIFY maxItemsChanged)
    Q_PROPERTY(QQmlListProperty<Shiny::Launcher::LauncherPlugin> plugins READ plugins NOTIFY pluginsChanged)
    Q_PROPERTY(Shiny::Launcher::LauncherPlugin* activePlugin READ activePlugin NOTIFY activePluginChanged)
    Q_PROPERTY(Shiny::Launcher::LauncherItemListModel* result READ result NOTIFY resultChanged)
    // clang-format on

  public:
    explicit LauncherDelegate(QObject* parent = nullptr);

    QString input() const;
    void setInput(const QString& input);

    qsizetype maxItems() const;
    void setMaxItems(qsizetype maxItems);

    QQmlListProperty<LauncherPlugin> plugins();

    LauncherPlugin* activePlugin() const;

    LauncherItemListModel* result() const;

  signals:
    void inputChanged();
    void maxItemsChanged();
    void pluginsChanged();
    void activePluginChanged();
    void resultChanged();

  private slots:
    void update();
    void resultReceived(QList<LauncherItem> items);

  private:
    QString m_input;
    qsizetype m_maxItems = std::numeric_limits<qsizetype>::max();
    QList<LauncherPlugin*> m_plugins;
    LauncherPlugin* m_activePlugin = nullptr;
    LauncherItemListModel* m_resultModel = new LauncherItemListModel(this);

    static void pluginsAppend(QQmlListProperty<LauncherPlugin>* property, LauncherPlugin* value);
    static qsizetype pluginsCount(QQmlListProperty<LauncherPlugin>* property);
    static LauncherPlugin* pluginsAt(QQmlListProperty<LauncherPlugin>* property, qsizetype index);
    static void pluginsClear(QQmlListProperty<LauncherPlugin>* property);
    static void pluginsReplace(
      QQmlListProperty<LauncherPlugin>* property,
      qsizetype index,
      LauncherPlugin* value
    );
    static void pluginsRemoveLast(QQmlListProperty<LauncherPlugin>* property);
  };
}
