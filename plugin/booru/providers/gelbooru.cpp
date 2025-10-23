#include "gelbooru.hpp"
#include <qcontainerfwd.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <qjsonvalue.h>
#include <qlist.h>
#include <qlogging.h>
#include <qnetworkrequest.h>
#include <qobject.h>
#include <qurlquery.h>

namespace Shiny::Booru::Providers {
  GelbooruBooruProvider::GelbooruBooruProvider(QObject* parent) : BooruNetworkProvider(parent) {}

  QString GelbooruBooruProvider::name() const {
    return "Gelbooru";
  }

  QString GelbooruBooruProvider::description() const {
    return "yay";
  }

  QUrl GelbooruBooruProvider::homeUrl() const {
    return QUrl("https://gelbooru.com/");
  };

  QNetworkRequest GelbooruBooruProvider::requestSearchPosts(
    const QString& search,
    bool allowNsfw,
    int limit,
    int page
  ) {
    QString tags = search;
    if (!allowNsfw) {
      tags += " -rating:explicit";
      tags += " -rating:questionable";
      tags += " -rating:sensitive";
    }

    QUrlQuery query;
    query.addQueryItem("user_id", m_apiUser);
    query.addQueryItem("api_key", m_apiKey);
    query.addQueryItem("page", "dapi");
    query.addQueryItem("s", "post");
    query.addQueryItem("q", "index");
    query.addQueryItem("json", QString::number(1));
    query.addQueryItem("limit", QString::number(limit));
    query.addQueryItem("pid", QString::number(page));
    query.addQueryItem("tags", tags);

    QUrl url("https://gelbooru.com/index.php");
    url.setQuery(query);

    return QNetworkRequest(url);
  };

  std::variant<QList<BooruPost>, QString> GelbooruBooruProvider::replySearchPosts(
    QNetworkReply* reply
  ) {
    QByteArray response = reply->readAll();
    QJsonDocument json = QJsonDocument::fromJson(response);
    if (!json.isObject())
      return "response is not valid json object";

    QJsonObject object = json.object();

    if (!object.value("post").isArray())
      return "missing field 'post' in response";

    QJsonArray postsArray = object.value("post").toArray();
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
      if (ratingStr == "general") {
        rating = BooruPost::Rating::Safe;
      } else if (ratingStr == "sensitive" || ratingStr == "questionable") {
        rating = BooruPost::Rating::Questionable;
      } else if (ratingStr == "explicit") {
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

      QUrlQuery postQuery;
      postQuery.addQueryItem("page", "post");
      postQuery.addQueryItem("s", "view");
      postQuery.addQueryItem("id", id);
      QUrl postUrl("https://gelbooru.com/index.php");
      postUrl.setQuery(postQuery);

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

  QNetworkRequest GelbooruBooruProvider::requestSuggestTags(const QString& input) {
    QUrlQuery query;
    query.addQueryItem("user_id", m_apiUser);
    query.addQueryItem("api_key", m_apiKey);
    query.addQueryItem("page", "dapi");
    query.addQueryItem("s", "tag");
    query.addQueryItem("q", "index");
    query.addQueryItem("json", QString::number(1));
    query.addQueryItem("limit", QString::number(TAGS_SUGGESTIONS_MAX));
    query.addQueryItem("orderby", "count");
    query.addQueryItem("name_pattern", input + "%");

    QUrl url("https://gelbooru.com/index.php");
    url.setQuery(query);

    return QNetworkRequest(url);
  }

  std::variant<QList<BooruTagSuggestion>, QString> GelbooruBooruProvider::replySuggestTags(
    QNetworkReply* reply
  ) {
    QByteArray response = reply->readAll();
    QJsonDocument json = QJsonDocument::fromJson(response);
    if (!json.isObject())
      return "response is not valid json object";

    QJsonObject object = json.object();

    if (!object.value("tag").isArray())
      return "missing field 'tag' in response";

    QJsonArray tagsArray = object.value("tag").toArray();
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

  QString GelbooruBooruProvider::apiUser() const {
    return m_apiUser;
  }

  void GelbooruBooruProvider::setApiUser(QString apiUser) {
    if (m_apiUser == apiUser)
      return;

    m_apiUser = apiUser;
    emit apiUserChanged();
  }

  QString GelbooruBooruProvider::apiKey() const {
    return m_apiKey;
  }

  void GelbooruBooruProvider::setApiKey(QString apiKey) {
    if (m_apiKey == apiKey)
      return;

    m_apiKey = apiKey;
    emit apiKeyChanged();
  }
}
