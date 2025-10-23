#include "data.hpp"
#include <utility>

namespace Shiny::Booru {
  BooruTagSuggestion::BooruTagSuggestion(QString name, int count) :
    m_name(std::move(name)), m_count(count) {}

  QString BooruTagSuggestion::name() const {
    return m_name;
  }

  int BooruTagSuggestion::count() const {
    return m_count;
  }

  bool BooruTagSuggestion::operator==(const BooruTagSuggestion& other) const {
    return other.m_name == m_name && other.m_count == m_count;
  }

  BooruPost::BooruPost(
    QString id,
    int width,
    int height,
    QList<QString> tags,
    Rating rating,
    QUrl previewUrl,
    QUrl imageUrl,
    QUrl postUrl,
    QUrl sourceUrl
  ) :
    m_id(std::move(id)), m_width(width), m_height(height), m_tags(tags), m_rating(rating),
    m_previewUrl(previewUrl), m_imageUrl(imageUrl), m_postUrl(postUrl), m_sourceUrl(sourceUrl) {}

  QString BooruPost::id() const {
    return m_id;
  }

  int BooruPost::width() const {
    return m_width;
  }

  int BooruPost::height() const {
    return m_height;
  }

  QList<QString> BooruPost::tags() const {
    return m_tags;
  }

  BooruPost::Rating BooruPost::rating() const {
    return m_rating;
  }

  bool BooruPost::nsfw() const {
    return m_rating != Rating::Safe;
  }

  QUrl BooruPost::previewUrl() const {
    return m_previewUrl;
  }

  QUrl BooruPost::imageUrl() const {
    return m_imageUrl;
  }

  QUrl BooruPost::postUrl() const {
    return m_postUrl;
  }

  QUrl BooruPost::sourceUrl() const {
    return m_sourceUrl;
  }

  bool BooruPost::operator==(const BooruPost& other) const {
    return other.m_id == m_id && other.m_width == m_width && other.m_height == m_height &&
      other.m_tags == m_tags && other.m_rating == m_rating && other.m_previewUrl == m_previewUrl &&
      other.m_imageUrl == m_imageUrl && other.m_postUrl == m_postUrl &&
      other.m_sourceUrl == m_sourceUrl;
  }
}
