#pragma once

#include <functional>
#include <qabstractitemmodel.h>
#include <qhash.h>
#include <qlist.h>
#include <qobjectdefs.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qstringview.h>
#include <qtmetamacros.h>

namespace Shiny::Launcher {
  class LauncherItem {
    Q_GADGET
    QML_ANONYMOUS

    // clang-format off
    Q_PROPERTY(bool isSystemIcon READ isSystemIcon CONSTANT)
    Q_PROPERTY(QString icon READ icon CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    // clang-format on

  public:
    LauncherItem() = default;
    LauncherItem(const LauncherItem& other) = default;
    explicit LauncherItem(
      bool isSystemIcon,
      QString icon,
      QString name,
      QString description,
      std::function<void()> handler
    );

    bool isSystemIcon() const;
    QString icon() const;
    QString name() const;
    QString description() const;

    bool operator==(const LauncherItem& other) const;

  public slots:
    Q_INVOKABLE void invoke() const;

  private:
    bool m_isSystemIcon = false;
    QString m_icon;
    QString m_name;
    QString m_description;
    std::function<void()> m_handler;
  };

  class LauncherItemListModel : public QAbstractListModel {
    Q_OBJECT
    QML_ANONYMOUS

  public:
    enum Roles { IsSystemIconRole = Qt::UserRole + 1, IconRole, NameRole, DescriptionRole };

    explicit LauncherItemListModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool setItems(const QList<Shiny::Launcher::LauncherItem>& items);
    Q_INVOKABLE void invoke(int index) const;

  private:
    QList<Shiny::Launcher::LauncherItem> m_items;
  };
}
