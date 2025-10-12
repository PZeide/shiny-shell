#pragma once

#include "../plugin.hpp"
#include <qcontainerfwd.h>
#include <qlist.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Launcher::Plugins {
  class WebSearchPlugin : public LauncherPlugin {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QString searchUrl READ searchUrl WRITE setSearchUrl NOTIFY searchUrlChanged REQUIRED)
    // clang-format on

  public:
    explicit WebSearchPlugin(QObject* parent = nullptr);

    QList<LauncherItem> filter(const QString& input, qsizetype max) const override;
    bool canActivate(const QString& input) const override;
    int priority() const override;
    QString name() const override;

    QString searchUrl() const;
    void setSearchUrl(QString searchUrl);

  signals:
    void searchUrlChanged();

  private:
    QString m_searchUrl;

    void invoke(const QString& search) const;
  };
} // namespace Shiny::Launcher::Plugins
