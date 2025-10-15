pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Shiny.Services.Weather
import qs.config
import qs.services

Singleton {
  id: root

  readonly property bool isAvailable: now !== null
  property alias now: provider.now

  function reload() {
    provider.refresh();
  }

  WeatherProvider {
    id: provider

    enabled: Config.location.enabled && Location.isAvailable
    refreshInterval: Config.location.weatherRefreshInterval
    latitude: Location.current?.latitude ?? 0
    longitude: Location.current?.longitude ?? 0
  }

  Connections {
    target: Location

    function onCurrentChanged() {
      provider.refresh();
    }
  }

  IpcHandler {
    target: "weather"

    function refresh() {
      root.reload();
    }
  }
}
