#include "websearch.hpp"

#include "../delegate.hpp"
#include "../item.hpp"
#include "../plugin.hpp"
#include <functional>
#include <qcontainerfwd.h>
#include <qdesktopservices.h>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <qproperty.h>
#include <qtmetamacros.h>
#include <qtypes.h>
#include <qurl.h>

namespace Shiny::Launcher::Plugins {

WebSearchPlugin::WebSearchPlugin(QObject* parent) : Shiny::Launcher::LauncherPlugin(parent) {}

QString WebSearchPlugin::name() const { return "Web search"; }

int WebSearchPlugin::priority() const { return PREFIXED_PLUGIN_PRIORITY; }

bool WebSearchPlugin::canActivate(const QString& input) const { return input.startsWith("?"); }

void WebSearchPlugin::filter(const QString& input, qsizetype) {
    QString searchTerm = input;
    if (searchTerm.startsWith("?"))
        searchTerm = searchTerm.mid(1).trimmed();

    if (searchTerm.isEmpty()) {
        emit filterResult({});
        return;
    }

    QString name = QString("Search for \"%1\"").arg(searchTerm);
    emit filterResult(
        {LauncherItem(false, "explore", name, "", std::bind_front(&WebSearchPlugin::invoke, this, searchTerm))});
}

QBindable<QString> WebSearchPlugin::bindableSearchUrl() { return &b_searchUrl; }

void WebSearchPlugin::invoke(const QString& search) const {
    QString strUrl = *b_searchUrl;
    strUrl.replace("%s", QUrl::toPercentEncoding(search));
    QUrl url = QUrl(strUrl);

    if (url.scheme() != "http" && url.scheme() != "https") {
        qCWarning(logLauncher) << "Cannot make a websearch to a non HTTP url";
        return;
    }

    if (!QDesktopServices::openUrl(url))
        qCWarning(logLauncher) << "Failed to make the websearch";
}

} // namespace Shiny::Launcher::Plugins
