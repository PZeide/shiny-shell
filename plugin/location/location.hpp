#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

namespace Shiny::Location {

class Location : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Location is retrieved from LocationProvider")

    Q_PROPERTY(double latitude READ latitude CONSTANT)
    Q_PROPERTY(double longitude READ longitude CONSTANT)
    Q_PROPERTY(QString city READ city CONSTANT)
    Q_PROPERTY(QString region READ region CONSTANT)
    Q_PROPERTY(QString country READ country CONSTANT)
    Q_PROPERTY(QString countryCode READ countryCode CONSTANT)

public:
    explicit Location(double latitude, double longitude, QString city, QString region, QString country,
                      QString countryCode, QObject* parent = nullptr);

    double latitude() const;
    double longitude() const;
    const QString city() const;
    const QString region() const;
    const QString country() const;
    const QString countryCode() const;

    bool operator==(const Location& other) const;
    bool operator!=(const Location& other) const;

private:
    const double m_latitude;
    const double m_longitude;
    const QString m_city;
    const QString m_region;
    const QString m_country;
    const QString m_countryCode;
};

} // namespace Shiny::Location
