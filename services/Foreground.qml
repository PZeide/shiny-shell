pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Shiny.Services.BackgroundRemoval
import qs.config
import qs.utils

Singleton {
  id: root

  readonly property bool unitEnabled: Config.wallpaper.foreground && Config.wallpaper.customForegroundPath === ""
  readonly property bool isAvailable: Config.wallpaper.foreground && (!unitEnabled || foregroundUnit.available)
  readonly property string path: unitEnabled ? foregroundUnit.result : Config.wallpaper.customForegroundPath

  BackgroundRemovalUnit {
    id: foregroundUnit

    cacheDirectory: Paths.toPlain(Paths.cacheUrl)
    source: root.unitEnabled ? Config.wallpaper.path : ""

    onProcessingChanged: {
      if (processing) {
        console.info(`Started processing foreground for path ${Config.wallpaper.path}`);
      }
    }

    onAvailableChanged: {
      if (available) {
        console.info(`Foreground available at ${result}`);
      }
    }
  }
}
