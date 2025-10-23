#pragma once

#include "data.hpp"
#include <qloggingcategory.h>
#include <qnetworkaccessmanager.h>
#include <qnetworkreply.h>
#include <qnetworkrequest.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qurl.h>
#include <variant>

namespace Shiny::Booru {
  Q_DECLARE_LOGGING_CATEGORY(logBooru)

  constexpr int TAGS_SUGGESTIONS_MAX = 10;

  class BooruProvider : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use a subclass of BooruProvider inside Shiny.Booru.Providers")

    // clang-format off
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QUrl homeUrl READ homeUrl CONSTANT)
    // clang-format on

  public:
    explicit BooruProvider(QObject* parent = nullptr);
    virtual ~BooruProvider() = default;

    virtual QString name() const = 0;
    virtual QString description() const = 0;
    virtual QUrl homeUrl() const = 0;

    Q_INVOKABLE virtual void searchPosts(
      const QString& query,
      bool allowNsfw,
      int limit,
      int page
    ) = 0;

    Q_INVOKABLE virtual void suggestTags(const QString& input) = 0;

  signals:
    void postsResult(const QList<Shiny::Booru::BooruPost>& posts);
    void postsError(const QString& message);
    void tagsSuggested(const QList<Shiny::Booru::BooruTagSuggestion>& suggestions);
    void tagsError(const QString& message);
  };

  class BooruNetworkProvider : public BooruProvider {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Use a subclass of BooruNetworkProvider inside Shiny.Booru.Providers")

  public:
    explicit BooruNetworkProvider(QObject* parent = nullptr);
    virtual ~BooruNetworkProvider() = default;

    void searchPosts(const QString& search, bool allowNsfw, int limit, int page) override;
    void suggestTags(const QString& search) override;

    virtual QNetworkRequest requestSearchPosts(
      const QString& search,
      bool allowNsfw,
      int limit,
      int page
    ) = 0;
    virtual std::variant<QList<BooruPost>, QString> replySearchPosts(QNetworkReply* reply) = 0;
    virtual QNetworkRequest requestSuggestTags(const QString& search) = 0;
    virtual std::variant<QList<BooruTagSuggestion>, QString> replySuggestTags(
      QNetworkReply* reply
    ) = 0;

  private slots:
    void resultSearchPosts(QNetworkReply* reply);
    void resultSuggestTags(QNetworkReply* reply);

  private:
    QNetworkAccessManager m_networkManager;
    quint64 m_postsRequestTracker = 0;
    quint64 m_tagsRequestTracker = 0;
  };
}
