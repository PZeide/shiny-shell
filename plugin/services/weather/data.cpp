#include "data.hpp"
#include <qnumeric.h>

namespace Shiny::Services::Weather {
  WeatherData::WeatherData(
    QString condition,
    QString icon,
    qreal temperature,
    bool isDay,
    QObject* parent
  ) :
    QObject(parent), m_condition(std::move(condition)), m_icon(std::move(icon)),
    m_temperature(temperature), m_isDay(isDay) {}

  QString WeatherData::condition() const {
    return m_condition;
  }

  QString WeatherData::icon() const {
    return m_icon;
  }

  qreal WeatherData::temperature() const {
    return m_temperature;
  }

  bool WeatherData::isDay() const {
    return m_isDay;
  }

  bool WeatherData::operator==(const WeatherData& other) const {
    return other.m_condition == this->m_condition && other.m_icon == this->m_icon &&
      qFuzzyCompare(other.m_temperature, this->m_temperature) && other.m_isDay == this->m_isDay;
  }
} // namespace Shiny::Services::Weather
