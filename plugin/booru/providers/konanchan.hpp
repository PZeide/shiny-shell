#include "../provider.hpp"
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace Shiny::Booru::Providers {
  class KonanchanBooruProvider : public BooruNetworkProvider {
    Q_OBJECT
    QML_ELEMENT

  public:
    explicit KonanchanBooruProvider(QObject* parent = nullptr);

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
  };
}
