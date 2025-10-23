#pragma once

#include <qmetaobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qurl.h>

namespace Shiny::Booru {
  class BooruTagSuggestion {
    Q_GADGET
    QML_ANONYMOUS

    // clang-format off
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(int count READ count CONSTANT)
    // clang-format on

  public:
    BooruTagSuggestion() = default;
    BooruTagSuggestion(const BooruTagSuggestion& other) = default;
    explicit BooruTagSuggestion(QString name, int count);

    QString name() const;
    int count() const;

    bool operator==(const BooruTagSuggestion& other) const;

  private:
    QString m_name;
    int m_count;
  };

  class BooruPost {
    Q_GADGET
    QML_ANONYMOUS

    // clang-format off
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(int width READ width CONSTANT)
    Q_PROPERTY(int height READ height CONSTANT)
    Q_PROPERTY(QList<QString> tags READ tags CONSTANT)
    Q_PROPERTY(Shiny::Booru::BooruPost::Rating rating READ rating CONSTANT)
    Q_PROPERTY(bool nsfw READ nsfw CONSTANT)
    Q_PROPERTY(QUrl previewUrl READ previewUrl CONSTANT)
    Q_PROPERTY(QUrl imageUrl READ imageUrl CONSTANT)
    Q_PROPERTY(QUrl postUrl READ postUrl CONSTANT)
    Q_PROPERTY(QUrl sourceUrl READ sourceUrl CONSTANT)
    // clang-format on

  public:
    enum class Rating { Safe, Questionable, Explicit };
    Q_ENUM(Rating)

    BooruPost() = default;
    BooruPost(const BooruPost& other) = default;
    explicit BooruPost(
      QString id,
      int width,
      int height,
      QList<QString> tags,
      Rating rating,
      QUrl previewUrl,
      QUrl imageUrl,
      QUrl postUrl,
      QUrl sourceUrl
    );

    QString id() const;
    int width() const;
    int height() const;
    QList<QString> tags() const;
    Rating rating() const;
    bool nsfw() const;
    QUrl previewUrl() const;
    QUrl imageUrl() const;
    QUrl postUrl() const;
    QUrl sourceUrl() const;

    bool operator==(const BooruPost& other) const;

  private:
    QString m_id;
    int m_width;
    int m_height;
    QList<QString> m_tags;
    Rating m_rating;
    QUrl m_previewUrl;
    QUrl m_imageUrl;
    QUrl m_postUrl;
    QUrl m_sourceUrl;
  };
}
