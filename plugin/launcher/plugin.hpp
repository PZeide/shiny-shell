#pragma once

#include "item.hpp"
#include <qlist.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <qtypes.h>

constexpr int CATCHALL_PLUGIN_PRIORITY = 1;
constexpr int PREFIXED_PLUGIN_PRIORITY = 10;

namespace Shiny::Launcher {
  class LauncherPlugin : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use a subclass of LauncherPlugin inside Shiny.Launcher.Plugins")

    // clang-format off
    Q_PROPERTY(int priority READ priority CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    // clang-format on

  public:
    explicit LauncherPlugin(QObject* parent = nullptr);
    virtual ~LauncherPlugin() = default;

    virtual QList<LauncherItem> filter(const QString& input, qsizetype max) const = 0;
    virtual bool canActivate(const QString& input) const = 0;
    virtual int priority() const = 0;
    virtual QString name() const = 0;
  };
} // namespace Shiny::Launcher
