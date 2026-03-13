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
import Quickshell.Services.Greetd
import qs.utils
import qs.layers.wallpaper

ShellRoot {
  settings.watchFiles: Environment.isDev

  readonly property string session: Quickshell.env("SHINYSHELL_GREETER_SESSION")
  readonly property string user: Quickshell.env("SHINYSHELL_GREETER_USER")

  FloatingWindow {
    id: window
    fullscreen: true

    WallpaperImage {
      imageWidth: window.width
      imageHeight: window.height
    }
  }

  Connections {
    function onAuthMessage(message, error, responseRequired, echoResponse) {
      console.log("[MSG] " + message);
      console.log("[ERR] " + error);
      console.log("[RESREQ] " + responseRequired);
      console.log("[ECHO] " + echoResponse);

      if (responseRequired) {
        Greetd.respond("Thibaud");
      }
    }

    function onReadyToLaunch() {
      console.log("[GREETD EXEC] thibaud");
      Greetd.launch("exec uwsm start -eD Hyprland hyprland.desktop");
    }

    target: Greetd
  }

  Component.onCompleted: {
    Greetd.createSession("thibaud");
  }
}
