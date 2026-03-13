#include "location.hpp"

#include <qnumeric.h>
#include <qobject.h>
#include <utility>

namespace Shiny::Location {

Location::Location(double latitude, double longitude, QString city, QString region, QString country,
                   QString countryCode, QObject* parent)
    : QObject(parent), m_latitude(latitude), m_longitude(longitude), m_city(std::move(city)),
      m_region(std::move(region)), m_country(std::move(country)), m_countryCode(std::move(countryCode)) {}

double Location::latitude() const { return m_latitude; }

double Location::longitude() const { return m_longitude; }

const QString Location::city() const { return m_city; }

const QString Location::region() const { return m_region; }

const QString Location::country() const { return m_country; }

const QString Location::countryCode() const { return m_countryCode; }

bool Location::operator==(const Location& other) const {
    return qFuzzyCompare(m_latitude, other.m_latitude) && qFuzzyCompare(m_longitude, other.m_longitude) &&
           m_city == other.m_city && m_region == other.m_region && m_country == other.m_country &&
           m_countryCode == other.m_countryCode;
}

bool Location::operator!=(const Location& other) const { return !(*this == other); }

} // namespace Shiny::Location
