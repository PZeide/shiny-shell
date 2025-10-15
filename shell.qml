pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.services
import qs.utils
import qs.layers.lockscreen
import qs.layers.corner
import qs.layers.bar
import qs.layers.wallpaper
import qs.layers.launcher
import qs.layers.overview

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
        activeAsync: Config.bar.enabled

        Bar {
          screen: scope.modelData
        }
      }

      LazyLoader {
        activeAsync: Config.launcher.enabled

        Launcher {
          screen: scope.modelData
        }
      }

      LazyLoader {
        activeAsync: Config.overview.enabled

        Overview {
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

  Connections {
    target: Hyprland

    // We use some properties not exposed by Quickshell so we update everything on each event
    function onRawEvent() {
      Hyprland.refreshMonitors();
      Hyprland.refreshWorkspaces();
      Hyprland.refreshToplevels();
    }
  }

  Component.onCompleted: {
    Location;
    Weather;
    Foreground;
    Player;
  }
}
