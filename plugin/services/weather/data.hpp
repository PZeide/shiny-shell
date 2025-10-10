#pragma once

#include <QObject>
#include <QString>
#include <QtQmlIntegration>
#include <QtTypes>

namespace Shiny::Services::Weather {
  class WeatherData : public QObject {
    Q_OBJECT
    QML_ANONYMOUS

    Q_PROPERTY(QString condition READ condition CONSTANT)
    Q_PROPERTY(QString icon READ icon CONSTANT)
    Q_PROPERTY(qreal temperature READ temperature CONSTANT)
    Q_PROPERTY(bool isDay READ isDay CONSTANT)

  public:
    explicit WeatherData(QString condition, QString icon, qreal temperature, bool isDay, QObject* parent = nullptr);

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
