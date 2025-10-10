#include "data.hpp"

#include <QtNumeric>

namespace Shiny::Services::Location {
  LocationData::LocationData(qreal latitude, qreal longitude, QString countryCode, QString countryName, QString city,
                             QObject* parent)
      : QObject(parent), m_latitude(latitude), m_longitude(longitude), m_countryCode(std::move(countryCode)),
        m_countryName(std::move(countryName)), m_city(std::move(city)) {}

  qreal LocationData::latitude() const {
    return m_latitude;
  }

  qreal LocationData::longitude() const {
    return m_longitude;
  }

  QString LocationData::countryCode() const {
    return m_countryCode;
  }

  QString LocationData::countryName() const {
    return m_countryName;
  }

  QString LocationData::city() const {
    return m_city;
  }

  bool LocationData::operator==(const LocationData& other) const {
    return qFuzzyCompare(other.m_latitude, this->m_latitude) && qFuzzyCompare(other.m_longitude, this->m_longitude) &&
           other.m_countryCode == this->m_countryCode && other.m_countryName == this->m_countryName &&
           other.m_city == this->m_city;
  }
} // namespace Shiny::Services::Location
