#include "fuzzyengine.hpp"
#include <algorithm>
#include <cstdio>
#include <qcontainerfwd.h>
#include <qhashfunctions.h>
#include <qlist.h>
#include <qobject.h>
#include <qtypes.h>
#include <qvariant.h>
#include <rapidfuzz/distance/JaroWinkler.hpp>
#include <string>

namespace Shiny {
  FuzzyPropertyDefinition::FuzzyPropertyDefinition(QString& property, qreal weight)
      : property(property), weight(weight) {}

  FuzzyEngine::FuzzyEngine(QObject* parent) : QObject(parent) {}

  qreal FuzzyEngine::similarity(const QString& first, const QString& second) const {
    return rapidfuzz::jaro_winkler_normalized_similarity(first.toLower().toStdString(), second.toLower().toStdString());
  }

  QList<const QObject*> FuzzyEngine::sort(const QString& query, const QList<const QObject*>& choices,
                                          const QList<FuzzyPropertyDefinition>& definitions,
                                          const qsizetype maxResults) const {
    using ScoredResult = QPair<const QObject*, qreal>;
    rapidfuzz::CachedJaroWinkler<quint32> scorer(query.toLower().toUtf8());
    QList<ScoredResult> results;
    results.reserve(choices.size());

    for (auto& choice : choices) {
      qreal totalWeight = 0;
      qreal scoreSum = 0;

      for (auto& definition : definitions) {
        totalWeight += definition.weight;

        QVariant property = choice->property(definition.property.toStdString().c_str());

        if (!property.isValid())
          continue;

        QString value = property.toString().toLower();
        if (value.isEmpty())
          continue;

        double score = scorer.normalized_similarity(value.toUtf8());
        scoreSum += score * definition.weight;
      }

      qreal normalizedScore = (totalWeight > 0) ? (scoreSum / totalWeight) : 0;
      results.emplace_back(choice, normalizedScore);
    }

    qsizetype resultCount = std::min(maxResults, results.size());
    std::partial_sort(results.begin(), results.begin() + resultCount, results.end(),
                      [](const ScoredResult& a, const ScoredResult& b) { return a.second > b.second; });

    QList<const QObject*> sortedChoices;
    sortedChoices.reserve(resultCount);
    for (qsizetype i = 0; i < resultCount; ++i) {
      sortedChoices.append(results[i].first);
    }

    return sortedChoices;
  }
} // namespace Shiny
