//@ pragma ShellId shiny-shell
//@ pragma AppId com.shiny-shell
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
import qs.services
import qs.config
import qs.layers.bar
import qs.layers.launcher
import qs.layers.lockscreen
import qs.layers.osd
import qs.layers.polkit
import qs.layers.region_selector
import qs.layers.share_picker
import qs.layers.wallpaper

ShellRoot {
  settings.watchFiles: Quickshell.env("SHINYSHELL_ENVIRONMENT") === "dev"

  Wallpaper {}
  Bar {}
  RegionSelector {}

  LazyLoader {
    activeAsync: Config.launcher.enabled
    Launcher {}
  }

  LazyLoader {
    activeAsync: Config.lockScreen.enabled
    LockScreen {}
  }

  LazyLoader {
    activeAsync: false
    Osd {}
  }

  LazyLoader {
    activeAsync: Config.polkit.enabled
    Polkit {}
  }

  LazyLoader {
    activeAsync: Config.sharePicker.enabled
    SharePicker {}
  }

  Component.onCompleted: {
    console.info("Late initialize services");

    Audio;
    Battery;
    Brightness;
    Clock;
    Host;
    HyprCompositor;
    //Notifications;
    Player;
    ScreenRecorder;
    Session;
  }
}
