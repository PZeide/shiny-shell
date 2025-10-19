pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.utils
import qs.config
import qs.layers.corner
import qs.layers.wallpaper
import qs.layers.bar
import qs.layers.lockscreen
import qs.layers.overview
import qs.layers.launcher
import qs.modules

ShellRoot {
  settings.watchFiles: Environment.isDev

  ScreenCorners {}

  Loader {
    active: Config.wallpaper.enabled
    sourceComponent: Wallpaper {}
  }

  Loader {
    active: Config.bar.enabled
    sourceComponent: Bar {}
  }

  Loader {
    active: Config.lockScreen.enabled
    sourceComponent: LockScreen {}
  }

  Loader {
    active: Config.overview.enabled
    sourceComponent: Overview {}
  }

  Loader {
    active: Config.launcher.enabled
    sourceComponent: Launcher {}
  }

  Loader {
    active: Config.idle.enabled
    sourceComponent: IdleManager {}
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
    Brightness;
    Foreground;
    Location;
    Weather;
    Player;
  }
}
