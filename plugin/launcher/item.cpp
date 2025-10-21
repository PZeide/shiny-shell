#include "item.hpp"
#include "delegate.hpp"
#include <qlogging.h>

namespace Shiny::Launcher {
  LauncherItem::LauncherItem(
    bool isSystemIcon,
    QString icon,
    QString name,
    QString description,
    std::function<void()> handler
  ) :
    m_isSystemIcon(isSystemIcon), m_icon(std::move(icon)), m_name(std::move(name)),
    m_description(std::move(description)), m_handler(std::move(handler)) {}

  bool LauncherItem::isSystemIcon() const {
    return m_isSystemIcon;
  }

  QString LauncherItem::icon() const {
    return m_icon;
  }

  QString LauncherItem::name() const {
    return m_name;
  }

  QString LauncherItem::description() const {
    return m_description;
  }

  bool LauncherItem::operator==(const LauncherItem& other) const {
    return other.m_isSystemIcon == this->m_isSystemIcon && other.m_icon == this->m_icon &&
      other.m_name == this->m_name && other.m_description == this->m_description;
  }

  void LauncherItem::invoke() const {
    if (m_handler) {
      m_handler();
    } else {
      qCWarning(logLauncher) << "LauncherItem is missing a defined handler";
    }
  }

  LauncherItemListModel::LauncherItemListModel(QObject* parent) : QAbstractListModel(parent) {}

  qint32 LauncherItemListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid())
      return 0;

    return static_cast<int>(m_items.size());
  }

  QHash<int, QByteArray> LauncherItemListModel::roleNames() const {
    return {
      {IsSystemIconRole, "isSystemIcon"},
      {IconRole, "icon"},
      {NameRole, "name"},
      {DescriptionRole, "description"}
    };
  }

  QVariant LauncherItemListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_items.size())
      return {};

    auto& item = m_items.at(index.row());

    switch (role) {
      case IsSystemIconRole:
        return item.isSystemIcon();
      case IconRole:
        return item.icon();
      case NameRole:
        return item.name();
      case DescriptionRole:
        return item.description();
      default:
        return {};
    }
  }

  QList<Shiny::Launcher::LauncherItem> LauncherItemListModel::items() {
    return m_items;
  }

  void LauncherItemListModel::setItems(const QList<Shiny::Launcher::LauncherItem>& items) {
    beginResetModel();
    m_items = items;
    endResetModel();
  }

  void LauncherItemListModel::invoke(int index) const {
    if (index < 0 || index >= m_items.size())
      return;

    m_items.at(index).invoke();
  }
}
