//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RHI_BACKEND=vulkan
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_MEDIA_BACKEND=ffmpeg
//@ pragma Env QT_FFMPEG_DECODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_FFMPEG_ENCODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.config
import qs.layers.bar
import qs.layers.launcher
import qs.layers.lockscreen
import qs.layers.overview
import qs.layers.polkit
import qs.layers.wallpaper

ShellRoot {
  settings.watchFiles: Quickshell.env("SHINYSHELL_ENVIRONMENT") === "dev"

  Wallpaper {}
  Bar {}

  LazyLoader {
    activeAsync: Config.launcher.enabled
    Launcher {}
  }

  LazyLoader {
    activeAsync: Config.lockScreen.enabled
    LockScreen {}
  }

  LazyLoader {
    activeAsync: Config.overview.enabled
    Overview {}
  }

  LazyLoader {
    activeAsync: Config.polkit.enabled
    Polkit {}
  }

  Connections {
    target: Hyprland

    readonly property list<string> refreshToplevelsEvents: ["openwindow", "closewindow", "movewindow", "movewindow2", "workspace", "workspacev2", "focusedmon", "focusedmonv2", "activewindow", "activewindowv2", "changefloatingmode", "fullscreen", "moveintogroup", "moveoutofgroup"]

    function onRawEvent(event) {
      if (refreshToplevelsEvents.includes(event.name)) {
        Hyprland.refreshToplevels();
      }
    }
  }

  Component.onCompleted: {
    console.info("Late initialize services");

    Audio;
    Battery;
    Brightness;
    //Notifications;
    Player;
    Session;
    ScreenRecorder;
  }
}
