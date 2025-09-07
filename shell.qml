pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Config
import qs.Services
import qs.Utils
import qs.Layers.Bar
import qs.Layers.LockScreen
import qs.Layers.Wallpaper

ShellRoot {
  settings.watchFiles: Env.isDev

  Loader {
    active: Config.lockScreen.enabled

    sourceComponent: LockScreen {}
  }

  Variants {
    model: Quickshell.screens

    Scope {
      id: scope

      property var modelData

      Loader {
        active: Config.wallpaper.enabled

        sourceComponent: Wallpaper {
          modelData: scope.modelData
        }
      }

      Loader {
        active: Config.bar.enabled

        sourceComponent: Bar {
          screen: scope.modelData
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
