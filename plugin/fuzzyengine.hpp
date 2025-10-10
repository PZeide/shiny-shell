#pragma once

#include <limits>
#include <qcontainerfwd.h>
#include <qlist.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny {
  class FuzzyPropertyDefinition {
    Q_GADGET
    QML_VALUE_TYPE(propertyDefinition)
    QML_STRUCTURED_VALUE

    Q_PROPERTY(QString property MEMBER property)
    Q_PROPERTY(qreal weight MEMBER weight)

  public:
    FuzzyPropertyDefinition() = default;
    explicit FuzzyPropertyDefinition(QString& property, qreal weight = 1);

    QString property;
    qreal weight;
  };

  class FuzzyEngine : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

  public:
    FuzzyEngine(QObject* parent = nullptr);

    Q_INVOKABLE qreal similarity(const QString& first, const QString& second) const;
    Q_INVOKABLE QList<const QObject*> sort(const QString& query, const QList<const QObject*>& choices,
                                           const QList<FuzzyPropertyDefinition>& definitions,
                                           const qsizetype maxResults = std::numeric_limits<qsizetype>::max()) const;
  };
} // namespace Shiny
