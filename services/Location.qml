pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Shiny.Services.Location
import qs.config

Singleton {
  id: root

  readonly property bool isAvailable: current !== null
  readonly property alias current: provider.current

  function refresh() {
    provider.refresh();
  }

  LocationProvider {
    id: provider

    enabled: Config.location.enabled
    refreshInterval: Config.location.refreshInterval

    onCurrentChanged: {
      console.info(`Location updated to '${current.city}, ${current.countryName}'`);
    }
  }

  IpcHandler {
    target: "location"

    function refresh() {
      console.info("Refreshing location from IPC");
      root.refresh();
    }
  }

  Component.onCompleted: {
    // Initial Location fetch
    if (Config.location.enabled) {
      refresh();
    }
  }
}
