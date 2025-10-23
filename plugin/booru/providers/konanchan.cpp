#include "konanchan.hpp"
#include <qcontainerfwd.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <qjsonvalue.h>
#include <qlist.h>
#include <qlogging.h>
#include <qnetworkrequest.h>
#include <qobject.h>
#include <qurl.h>
#include <qurlquery.h>

namespace Shiny::Booru::Providers {
  KonanchanBooruProvider::KonanchanBooruProvider(QObject* parent) : BooruNetworkProvider(parent) {}

  QString KonanchanBooruProvider::name() const {
    return "Konanchan";
  }

  QString KonanchanBooruProvider::description() const {
    return "yay2";
  }

  QUrl KonanchanBooruProvider::homeUrl() const {
    return QUrl("https://konachan.net/");
  };

  QNetworkRequest KonanchanBooruProvider::requestSearchPosts(
    const QString& search,
    bool allowNsfw,
    int limit,
    int page
  ) {
    QString tags = search;
    if (!allowNsfw) {
      tags += " -rating:e";
      tags += " -rating:q";
    }

    QUrlQuery query;
    query.addQueryItem("limit", QString::number(limit));
    query.addQueryItem("page", QString::number(page));
    query.addQueryItem("tags", tags);

    QUrl url("https://konachan.net/post.json");
    url.setQuery(query);

    return QNetworkRequest(url);
  };

  std::variant<QList<BooruPost>, QString> KonanchanBooruProvider::replySearchPosts(
    QNetworkReply* reply
  ) {
    QByteArray response = reply->readAll();
    QJsonDocument json = QJsonDocument::fromJson(response);
    if (!json.isArray())
      return "response is not valid json array";

    QJsonArray postsArray = json.array();
    QList<BooruPost> posts;
    posts.reserve(postsArray.count());

    for (const QJsonValue& value : postsArray) {
      if (!value.isObject())
        return "post is not a valid object";

      QJsonObject postObject = value.toObject();

      if (!postObject.value("id").isDouble())
        return "missing field 'id' in post";

      int idNum = postObject.value("id").toInt();
      QString id = QString::number(idNum);

      if (!postObject.value("width").isDouble())
        return "missing field 'width' in post";

      int width = postObject.value("width").toInt();

      if (!postObject.value("height").isDouble())
        return "missing field 'height' in post";

      int height = postObject.value("height").toInt();

      if (!postObject.value("tags").isString())
        return "missing field 'tags' in post";

      QList<QString> tags = postObject.value("tags").toString().split(" ");

      if (!postObject.value("rating").isString())
        return "missing field 'rating' in post";

      QString ratingStr = postObject.value("rating").toString();
      BooruPost::Rating rating;
      if (ratingStr == "s") {
        rating = BooruPost::Rating::Safe;
      } else if (ratingStr == "q") {
        rating = BooruPost::Rating::Questionable;
      } else if (ratingStr == "e") {
        rating = BooruPost::Rating::Explicit;
      } else {
        return "rating is invalid in post";
      }

      if (!postObject.value("preview_url").isString())
        return "missing field 'preview_url' in post";

      QUrl previewUrl(postObject.value("preview_url").toString());
      if (!previewUrl.isValid())
        return "invalid preview url in post";

      if (!postObject.value("file_url").isString())
        return "missing field 'file_url' in post";

      QUrl imageUrl(postObject.value("file_url").toString());
      if (!imageUrl.isValid())
        return "invalid image url in post";

      QUrl postUrl(QString("https://konachan.com/post/show/%1").arg(id));

      if (!postObject.value("source").isString())
        return "missing field 'source' in post";

      QUrl sourceUrl(postObject.value("source").toString());
      if (!sourceUrl.isValid()) {
        // empty url
        sourceUrl = QUrl();
      }

      posts.emplace_back(id, width, height, tags, rating, previewUrl, imageUrl, postUrl, sourceUrl);
    }

    return posts;
  }

  QNetworkRequest KonanchanBooruProvider::requestSuggestTags(const QString& input) {
    QUrlQuery query;
    query.addQueryItem("order", "count");
    query.addQueryItem("limit", QString::number(TAGS_SUGGESTIONS_MAX));
    query.addQueryItem("name_pattern", input + "%");

    QUrl url("https://konachan.net/tag.json");
    url.setQuery(query);

    return QNetworkRequest(url);
  }

  std::variant<QList<BooruTagSuggestion>, QString> KonanchanBooruProvider::replySuggestTags(
    QNetworkReply* reply
  ) {
    QByteArray response = reply->readAll();
    QJsonDocument json = QJsonDocument::fromJson(response);
    if (!json.isArray())
      return "response is not valid json array";

    QJsonArray tagsArray = json.array();
    QList<BooruTagSuggestion> tags;
    tags.reserve(tagsArray.count());

    for (const QJsonValue& value : tagsArray) {
      if (!value.isObject())
        return "tag is not a valid object";

      QJsonObject tagObject = value.toObject();

      if (!tagObject.value("name").isString())
        return "missing field 'name' in tag";

      QString name = tagObject.value("name").toString();

      if (!tagObject.value("count").isDouble())
        return "missing field 'count' in post";

      int count = tagObject.value("count").toInt();

      tags.emplace_back(name, count);
    }

    return tags;
  }
}
