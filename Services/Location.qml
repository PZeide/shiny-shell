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
  property LocationData current: null

  function reload() {
    // First set running to false if alreay running
    if (locationScript.running)
      locationScript.running = false;

    locationScript.running = true;
  }

  Process {
    id: locationScript

    command: ["bash", Paths.scriptPath("find-location.sh"), Config.location.provider]

    stdout: StdioCollector {
      onStreamFinished: {
        const result = this.text.trim();
        if (result) {
          const newLocationObj = JSON.parse(result);
          const newLocationData = locationDataFactory.createObject(root, newLocationObj);

          if (!Utils.deepEquals(newLocationData, root.current)) {
            console.info(`Updating location to '${result}'`);
            root.current = newLocationData;
          }
        }
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        const error = this.text.trim();
        if (error)
          console.error(`Failed to find location: ${error}`);
      }
    }
  }

  Timer {
    id: refreshLocationTimer

    running: Config.location.enabled
    repeat: true
    interval: Config.location.refreshInterval

    // Use running instead of exec to avoid restarting if process is already running
    onTriggered: locationScript.running = true
  }

  Connections {
    target: Config.location

    function onEnabledChanged() {
      if (Config.location.enabled) {
        root.reload();
      } else {
        locationScript.running = false;
        root.current = null;
      }
    }

    function onProviderChanged() {
      if (Config.location.enabled)
        root.reload();
    }
  }

  Component {
    id: locationDataFactory
    LocationData {}
  }

  Component.onCompleted: {
    if (Config.location.enabled)
      root.reload();
  }
}
