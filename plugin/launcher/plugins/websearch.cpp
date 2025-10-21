#include "websearch.hpp"
#include "../delegate.hpp"
#include <qdesktopservices.h>
#include <qlogging.h>
#include <qtmetamacros.h>
#include <qurl.h>

namespace Shiny::Launcher::Plugins {
  WebSearchPlugin::WebSearchPlugin(QObject* parent) : Shiny::Launcher::LauncherPlugin(parent) {}

  QString WebSearchPlugin::name() const {
    return "Web search";
  }

  int WebSearchPlugin::priority() const {
    return PREFIXED_PLUGIN_PRIORITY;
  }

  bool WebSearchPlugin::canActivate(const QString& input) const {
    return input.startsWith("?");
  }

  void WebSearchPlugin::filter(const QString& input, qsizetype) {
    QString searchTerm = input;
    if (searchTerm.startsWith("?"))
      searchTerm = searchTerm.mid(1).trimmed();

    if (searchTerm.isEmpty()) {
      emit filterResult({});
      return;
    }

    QString name = QString("Search for \"%1\"").arg(searchTerm);
    emit filterResult({LauncherItem(
      false,
      "explore",
      name,
      "",
      std::bind_front(&WebSearchPlugin::invoke, this, searchTerm)
    )});
  }

  QString WebSearchPlugin::searchUrl() const {
    return m_searchUrl;
  }

  void WebSearchPlugin::setSearchUrl(QString searchUrl) {
    if (m_searchUrl == searchUrl)
      return;

    m_searchUrl = searchUrl;
    emit searchUrlChanged();
  }

  void WebSearchPlugin::invoke(const QString& search) const {
    QString strUrl = m_searchUrl;
    strUrl.replace("%s", QUrl::toPercentEncoding(search));
    QUrl url = QUrl(strUrl);

    if (url.scheme() != "http" && url.scheme() != "https") {
      qCWarning(logLauncher) << "Cannot make a websearch to a non HTTP url";
      return;
    }

    if (!QDesktopServices::openUrl(url))
      qCWarning(logLauncher) << "Failed to make the websearch";
  }
}
