pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.utils
import qs.services.models

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

    command: Utils.scriptCommand("find-location.nu", Config.location.provider)

    stdout: StdioCollector {
      onStreamFinished: {
        const result = this.text.trim();
        if (result !== "") {
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
        const fullError = this.text.trim();
        if (fullError !== "") {
          const error = Utils.extractNuError(fullError);
          console.error(`Failed to find location: ${error}`);
        }
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

  IpcHandler {
    target: "location"

    function refresh() {
      console.info("Refreshing location from IPC");
      root.reload();
    }
  }

  Component.onCompleted: {
    if (Config.location.enabled)
      root.reload();
  }

  Component {
    id: locationDataFactory
    LocationData {}
  }
}
