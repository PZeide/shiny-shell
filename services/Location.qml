pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Shiny.Services
import qs.config

Singleton {
  id: root

  readonly property bool isAvailable: current !== null
  readonly property alias current: provider.current

  function refresh() {
    if (!provider.enabled)
      return;

    provider.refresh();
  }

  LocationProvider {
    id: provider
    refreshInterval: Config.location.refreshInterval
    enabled: Config.location.enabled

    onCurrentChanged: console.info(`Location updated to '${current.city}, ${current.countryName}'`)
  }

  IpcHandler {
    target: "location"

    function get(): string {
      return JSON.stringify(root.isAvailable ? {
        available: true,
        latitude: root.current.latitude,
        longitude: root.current.longitude,
        countryCode: root.current.countryCode,
        countryName: root.current.countryName,
        city: root.current.city
      } : {
        available: false
      });
    }

    function refresh(): string {
      if (!provider.enabled)
        return "unavailable";

      root.refresh();
      return "ok";
    }
  }

  Component.onCompleted: {
    // Initial Location fetch
    if (Config.location.enabled) {
      refresh();
    }
  }
}
