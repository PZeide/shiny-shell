pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Shiny.Services
import qs.config
import qs.services

Singleton {
  id: root

  readonly property bool isAvailable: now !== null
  property alias now: provider.now

  function reload() {
    if (!provider.enabled)
      return;

    provider.refresh();
  }

  WeatherProvider {
    id: provider
    refreshInterval: Config.location.weatherRefreshInterval
    latitude: Location.current?.latitude ?? 0
    longitude: Location.current?.longitude ?? 0
    enabled: Config.location.enabled && Location.isAvailable
  }

  Connections {
    target: Location

    function onCurrentChanged() {
      provider.refresh();
    }
  }

  IpcHandler {
    target: "weather"

    function get(): string {
      return JSON.stringify(root.isAvailable ? {
        available: true,
        condition: root.now.condition,
        icon: root.now.icon,
        temperature: root.now.temperature,
        isDay: root.now.isDay
      } : {
        available: false
      });
    }

    function refresh(): string {
      if (!provider.enabled)
        return "unavailable";

      root.reload();
      return "ok";
    }
  }
}
