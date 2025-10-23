#include "weather.hpp"
#include <qbytearray.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <qlogging.h>
#include <qobject.h>
#include <qurlquery.h>
#include <qvariant.h>

namespace Shiny::Services {
  Q_LOGGING_CATEGORY(logWeather, "shiny.services.weather", QtInfoMsg)

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

  WeatherProvider::WeatherProvider(QObject* parent) : QObject(parent) {
    connect(&m_networkManager, &QNetworkAccessManager::finished, this, &WeatherProvider::result);
    m_networkManager.setAutoDeleteReplies(true);

    connect(&m_refreshTimer, &QTimer::timeout, this, &WeatherProvider::refresh);
    m_refreshTimer.setTimerType(Qt::CoarseTimer);
    m_refreshTimer.setSingleShot(false);
    m_refreshTimer.setInterval(WEATHER_DEFAULT_REFRESH_INTERVAL_MSECS);
  }

  bool WeatherProvider::enabled() const {
    return m_enabled;
  }

  void WeatherProvider::setEnabled(bool enabled) {
    if (m_enabled == enabled)
      return;

    m_enabled = enabled;
    emit enabledChanged();

    if (enabled) {
      m_refreshTimer.start();
    } else {
      m_refreshTimer.stop();

      if (m_now) {
        m_now = nullptr;
        emit nowChanged();
      }
    }
  }

  int WeatherProvider::refreshInterval() const {
    return m_refreshTimer.interval();
  }

  void WeatherProvider::setRefreshInterval(int refreshInterval) {
    if (m_refreshTimer.interval() == refreshInterval)
      return;

    m_refreshTimer.setInterval(refreshInterval);
    emit refreshIntervalChanged();
  }

  qreal WeatherProvider::latitude() const {
    return m_latitude;
  }

  void WeatherProvider::setLatitude(qreal latitude) {
    if (qFuzzyCompare(m_latitude, latitude))
      return;

    m_latitude = latitude;
    emit latitudeChanged();
  }

  qreal WeatherProvider::longitude() const {
    return m_longitude;
  }

  void WeatherProvider::setLongitude(qreal longitude) {
    if (qFuzzyCompare(m_longitude, longitude))
      return;

    m_longitude = longitude;
    emit longitudeChanged();
  }

  WeatherData* WeatherProvider::now() const {
    return m_now.get();
  }

  void WeatherProvider::refresh() {
    if (!m_enabled)
      return;

    QUrlQuery query;
    query.addQueryItem("latitude", QString::number(m_latitude));
    query.addQueryItem("longitude", QString::number(m_longitude));
    query.addQueryItem("current", "temperature_2m,weather_code,is_day");

    QUrl url("https://api.open-meteo.com/v1/forecast");
    url.setQuery(query);

    QNetworkRequest request(url);
    QNetworkReply* reply = m_networkManager.get(request);
    reply->setProperty("tracker", ++m_requestTracker);
  }

  void WeatherProvider::result(QNetworkReply* reply) {
    if (!m_enabled)
      return;

    quint64 tracker = reply->property("tracker").toULongLong();
    if (tracker != m_requestTracker) {
      // Another request came through after, ignore this one
      return;
    }

    if (reply->error() != QNetworkReply::NoError) {
      qCWarning(logWeather) << "Failed to fetch weather:" << reply->errorString();
      return;
    }

    QByteArray response = reply->readAll();
    QJsonDocument json = QJsonDocument::fromJson(response);
    if (!json.isObject()) {
      qCWarning(logWeather) << "Failed to fetch weather: response is not valid json object";
      return;
    }

    QJsonObject object = json.object();

    if (!object.value("current").isObject()) {
      qCWarning(logWeather) << "Failed to fetch weather: current object is missing";
      return;
    }

    QJsonObject current = object.value("current").toObject();

    if (!current.value("temperature_2m").isDouble()) {
      qCWarning(logWeather) << "Failed to fetch weather: missing 'temperature_2m' field in current";
      return;
    }

    double temperature = current.value("temperature_2m").toDouble();

    if (!current.value("is_day").isDouble()) {
      qCWarning(logWeather) << "Failed to fetch weather: missing 'is_day' field in current";
      return;
    }

    bool isDay = current.value("is_day").toInt() == 1;

    if (!current.value("weather_code").isDouble()) {
      qCWarning(logWeather) << "Failed to fetch weather: missing 'weather_code' field in current";
      return;
    }

    int weatherCode = current.value("weather_code").toInt();
    QString condition;
    QString icon;

    switch (weatherCode) {
      case 0:
        condition = "Clear sky";
        icon = QString("clear_%1").arg(isDay ? "day" : "night");
        break;

      case 1:
        condition = "Mainly clear";
        icon = QString("partly_cloudy_%1").arg(isDay ? "day" : "night");
        break;

      case 2:
        condition = "Partly cloudy";
        icon = QString("partly_cloudy_%1").arg(isDay ? "day" : "night");
        break;

      case 3:
        condition = "Cloudy";
        icon = "cloud";
        break;

      case 45:
      case 48:
        condition = "Foggy";
        icon = "foggy";
        break;

      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        condition = "Drizzle";
        icon = "grain";
        break;

      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        condition = "Rain";
        icon = "rainy";
        break;

      case 71:
      case 73:
      case 75:
      case 77:
        condition = "Snow";
        icon = "ac_unit";
        break;

      case 80:
      case 81:
      case 82:
        condition = "Rain showers";
        icon = "rainy";
        break;

      case 85:
      case 86:
        condition = "Snow showers";
        icon = "ac_unit";
        break;

      case 95:
        condition = "Thunderstorm";
        icon = "thunderstorm";
        break;

      case 96:
      case 99:
        condition = "Thunderstorm with hail";
        icon = "thunderstorm";
        break;

      default:
        qCWarning(logWeather) << "Failed to fetch weather: invalid wheather code" << weatherCode;
        return;
    }

    m_now = std::make_unique<WeatherData>(condition, icon, temperature, isDay);
    emit nowChanged();
  }
}
