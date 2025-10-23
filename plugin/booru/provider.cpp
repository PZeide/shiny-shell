#include "provider.hpp"
#include "data.hpp"
#include <qloggingcategory.h>
#include <qnetworkreply.h>
#include <qnetworkrequest.h>
#include <qobject.h>
#include <variant>

namespace Shiny::Booru {
  Q_LOGGING_CATEGORY(logBooru, "shiny.booru", QtInfoMsg)

  BooruProvider::BooruProvider(QObject* parent) : QObject(parent) {}

  BooruNetworkProvider::BooruNetworkProvider(QObject* parent) : BooruProvider(parent) {
    m_networkManager.setAutoDeleteReplies(true);
  }

  void BooruNetworkProvider::searchPosts(
    const QString& search,
    bool allowNsfw,
    int limit,
    int page
  ) {
    QNetworkRequest request = requestSearchPosts(search, allowNsfw, limit, page);
    QNetworkReply* reply = m_networkManager.get(request);
    reply->setProperty("tracker", ++m_postsRequestTracker);
    connect(reply, &QNetworkReply::finished, this, [this, reply] { resultSearchPosts(reply); });
  }

  void BooruNetworkProvider::suggestTags(const QString& search) {
    QNetworkRequest request = requestSuggestTags(search);
    QNetworkReply* reply = m_networkManager.get(request);
    reply->setProperty("tracker", ++m_tagsRequestTracker);
    connect(reply, &QNetworkReply::finished, this, [this, reply] { resultSuggestTags(reply); });
  }

  void BooruNetworkProvider::resultSearchPosts(QNetworkReply* reply) {
    quint64 tracker = reply->property("tracker").toULongLong();
    if (tracker != m_postsRequestTracker) {
      // Another request came through after, ignore this one
      return;
    }

    if (reply->error() != QNetworkReply::NoError) {
      qCWarning(logBooru) << "Failed to fetch posts on" << this->name()
                          << "because of error:" << reply->errorString();
      emit postsError("Failed to fetch post results");
      return;
    }

    auto result = replySearchPosts(reply);
    if (std::holds_alternative<QList<BooruPost>>(result)) {
      emit postsResult(std::get<QList<BooruPost>>(result));
    } else {
      emit postsError(QString("Failed to fetch post results: %1").arg(std::get<QString>(result)));
    }
  }

  void BooruNetworkProvider::resultSuggestTags(QNetworkReply* reply) {
    quint64 tracker = reply->property("tracker").toULongLong();
    if (tracker != m_tagsRequestTracker) {
      // Another request came through after, ignore this one
      return;
    }

    if (reply->error() != QNetworkReply::NoError) {
      qCWarning(logBooru) << "Failed to suggest tags on" << this->name()
                          << "because of error:" << reply->errorString();
      emit tagsError("Failed to suggest tags");
      return;
    }

    auto result = replySuggestTags(reply);
    if (std::holds_alternative<QList<BooruTagSuggestion>>(result)) {
      emit tagsSuggested(std::get<QList<BooruTagSuggestion>>(result));
    } else {
      emit tagsError(QString("Failed to suggest tags: %1").arg(std::get<QString>(result)));
    }
  }
}
