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
import qs.layers.osd
import qs.layers.session_control
import qs.layers.notification_popups

ShellRoot {
  settings.watchFiles: Environment.isDev

  Wallpaper {}
  ScreenCorners {}
  Bar {}

  LazyLoader {
    active: Config.lockScreen.enabled
    LockScreen {}
  }

  LazyLoader {
    active: Config.leftSidebar.enabled
    LeftSidebar {}
  }

  LazyLoader {
    active: Config.overview.enabled
    Overview {}
  }

  LazyLoader {
    active: Config.launcher.enabled
    Launcher {}
  }

  LazyLoader {
    active: Config.osd.enabled
    Osd {}
  }

  LazyLoader {
    active: Config.session.controlEnabled
    SessionControl {}
  }

  /*LazyLoader {
    active: Config.notification.enablePopups
    NotificationPopups {}
  }*/

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
    Notifications;
    Player;
    Session;
    Weather;
  }
}
