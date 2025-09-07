pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Utils
import qs.Services.Models

Singleton {
  id: root

  readonly property bool isAvailable: current !== null
  property WeatherData current: null

  function reload() {
    // First set running to false if alreay running
    if (weatherScript.running)
      weatherScript.running = false;

    weatherScript.running = true;
  }

  Process {
    id: weatherScript

    command: ["bash", Paths.scriptPath("get-weather.sh"), Location.current?.latitude, Location.current?.longitude]

    stdout: StdioCollector {
      onStreamFinished: {
        const result = this.text.trim();
        if (result) {
          const newWeatherObj = JSON.parse(result);
          const newWeatherData = weatherDataFactory.createObject(root, newWeatherObj);

          if (!Utils.deepEquals(newWeatherData, root.current)) {
            console.info(`Updating weather to '${result}'`);
            root.current = newWeatherData;
          }
        }
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        const error = this.text.trim();
        if (error)
          console.error(`Failed to get weather: ${error}`);
      }
    }
  }

  Timer {
    id: refreshWeatherTimer

    running: Config.location.enabled
    repeat: true
    interval: Config.location.weatherRefreshInterval

    // Use running instead of exec to avoid restarting if process is already running
    onTriggered: weatherScript.running = true
  }

  Connections {
    target: Location

    function onCurrentChanged() {
      if (Location.current !== null) {
        root.reload();
      } else {
        root.current = null;
        weatherScript.running = false;
      }
    }
  }

  Component {
    id: weatherDataFactory
    WeatherData {}
  }
}
