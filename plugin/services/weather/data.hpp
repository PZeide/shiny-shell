#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
#include <qstring.h>
#include <qtmetamacros.h>
#include <qtypes.h>

namespace Shiny::Services::Weather {
  class WeatherData : public QObject {
    Q_OBJECT
    QML_ANONYMOUS

    // clang-format off
    Q_PROPERTY(QString condition READ condition CONSTANT)
    Q_PROPERTY(QString icon READ icon CONSTANT)
    Q_PROPERTY(qreal temperature READ temperature CONSTANT)
    Q_PROPERTY(bool isDay READ isDay CONSTANT)
    // clang-format on

  public:
    explicit WeatherData(
      QString condition,
      QString icon,
      qreal temperature,
      bool isDay,
      QObject* parent = nullptr
    );

    QString condition() const;
    QString icon() const;
    qreal temperature() const;
    bool isDay() const;

    [[nodiscard]] bool operator==(const WeatherData& other) const;

  private:
    QString m_condition;
    QString m_icon;
    qreal m_temperature;
    bool m_isDay;
  };
} // namespace Shiny::Services::Weather
