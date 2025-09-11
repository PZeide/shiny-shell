pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.utils
import qs.layers.lockscreen
import qs.layers.corner
import qs.layers.wallpaper

ShellRoot {
  settings.watchFiles: Environment.isDev

  Loader {
    active: Config.lockScreen.enabled

    sourceComponent: LockScreen {}
  }

  Variants {
    model: Quickshell.screens

    Scope {
      id: scope

      property var modelData

      ScreenCorners {
        screen: scope.modelData
      }

      Loader {
        active: Config.wallpaper.enabled

        sourceComponent: Wallpaper {
          modelData: scope.modelData
        }
      }
    }
  }

  Connections {
    target: Quickshell

    function onReloadCompleted() {
      Quickshell.inhibitReloadPopup();
    }

    function onReloadFailed() {
      Quickshell.inhibitReloadPopup();
    }
  }

  Component.onCompleted: {
    // Services that needs to be initialized early for seamless usage (disable if dev)
    Foreground;
    Location;
    Weather;
  }
}
