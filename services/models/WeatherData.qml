pragma ComponentBehavior: Bound

import QtQuick
import qs.config

QtObject {
  required property string weather
  required property string icon
  required property real temperature
  readonly property string formattedTemperature: {
    if (Config.locale.temperatureUnit === "fahrenheit") {
      const convertedTemperature = temperature * 1.8 + 32;
      return convertedTemperature.toFixed(1) + " °F";
    } else {
      return temperature.toFixed(1) + " °C";
    }
  }
}
