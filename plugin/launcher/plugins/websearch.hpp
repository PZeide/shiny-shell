#pragma once

#include "../plugin.hpp"
#include <qcontainerfwd.h>
#include <qlist.h>
#include <qobject.h>
#include <qproperty.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Launcher::Plugins {

class WebSearchPlugin : public LauncherPlugin {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QString searchUrl READ default WRITE default NOTIFY searchUrlChanged BINDABLE bindableSearchUrl REQUIRED)
    // clang-format on

public:
    explicit WebSearchPlugin(QObject* parent = nullptr);

    QString name() const override;
    int priority() const override;
    bool canActivate(const QString& input) const override;
    void filter(const QString& input, qsizetype max) override;

    QBindable<QString> bindableSearchUrl();

signals:
    void searchUrlChanged();

private:
    // clang-format off
    Q_OBJECT_BINDABLE_PROPERTY(WebSearchPlugin, QString, b_searchUrl, &WebSearchPlugin::searchUrlChanged)
    // clang-format on

    void invoke(const QString& search) const;
};

} // namespace Shiny::Launcher::Plugins
