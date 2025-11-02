//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.utils
import qs.config
import qs.layers.wallpaper
import qs.layers.corner
import qs.layers.bar
import qs.layers.left_sidebar
import qs.layers.lockscreen
import qs.layers.overview
import qs.layers.launcher

ShellRoot {
  settings.watchFiles: Environment.isDev

  Wallpaper {}
  ScreenCorners {}
  Bar {}

  Loader {
    active: Config.leftSidebar.enabled
    sourceComponent: LeftSidebar {}
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
    DesktopEntries;

    Brightness;
    Foreground;
    Location;
    Player;
    Session;
    Weather;
  }
}
