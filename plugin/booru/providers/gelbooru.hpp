#include "../provider.hpp"
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace Shiny::Booru::Providers {
  class GelbooruBooruProvider : public BooruNetworkProvider {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QString apiUser READ apiUser WRITE setApiUser NOTIFY apiUserChanged REQUIRED)
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged REQUIRED)
    // clang-format on

  public:
    explicit GelbooruBooruProvider(QObject* parent = nullptr);

    QString name() const override;
    QString description() const override;
    QUrl homeUrl() const override;

    QNetworkRequest requestSearchPosts(
      const QString& search,
      bool allowNsfw,
      int limit,
      int page
    ) override;
    std::variant<QList<BooruPost>, QString> replySearchPosts(QNetworkReply* reply) override;
    QNetworkRequest requestSuggestTags(const QString& search) override;
    std::variant<QList<BooruTagSuggestion>, QString> replySuggestTags(
      QNetworkReply* reply
    ) override;

    QString apiUser() const;
    void setApiUser(QString apiUser);

    QString apiKey() const;
    void setApiKey(QString apiKey);

  signals:
    void apiUserChanged();
    void apiKeyChanged();

  private:
    QString m_apiUser;
    QString m_apiKey;
  };
}
