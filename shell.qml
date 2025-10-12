pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.utils
import qs.layers.lockscreen
import qs.layers.corner
import qs.layers.wallpaper
import qs.layers.launcher

ShellRoot {
  settings.watchFiles: Environment.isDev

  LazyLoader {
    activeAsync: Config.lockScreen.enabled

    LockScreen {}
  }

  Variants {
    model: Quickshell.screens

    Scope {
      id: scope

      property var modelData

      ScreenCorners {
        screen: scope.modelData
      }

      LazyLoader {
        activeAsync: Config.wallpaper.enabled

        Wallpaper {
          screen: scope.modelData
        }
      }

      LazyLoader {
        activeAsync: Config.launcher.enabled

        Launcher {
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
    Location;
    Weather;
    Foreground;
    Player;
  }
}
