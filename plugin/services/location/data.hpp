#pragma once

#include <QObject>
#include <QString>
#include <QtQmlIntegration>
#include <QtTypes>

namespace Shiny::Services::Location {
  class LocationData : public QObject {
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(qreal latitude READ latitude CONSTANT)
    Q_PROPERTY(qreal longitude READ longitude CONSTANT)
    Q_PROPERTY(QString countryCode READ countryCode CONSTANT)
    Q_PROPERTY(QString countryName READ countryName CONSTANT)
    Q_PROPERTY(QString city READ city CONSTANT)

  public:
    explicit LocationData(qreal latitude, qreal longitude, QString countryCode, QString countryName, QString city,
                          QObject* parent = nullptr);

    qreal latitude() const;
    qreal longitude() const;
    QString countryCode() const;
    QString countryName() const;
    QString city() const;

    [[nodiscard]] bool operator==(const LocationData& other) const;

  private:
    qreal m_latitude;
    qreal m_longitude;
    QString m_countryCode;
    QString m_countryName;
    QString m_city;
  };
} // namespace Shiny::Services::Location
