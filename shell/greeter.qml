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
import qs.layers.greeter

ShellRoot {
  id: root

  readonly property bool isDev: Quickshell.env("SHINYSHELL_ENVIRONMENT") === "dev"
  readonly property string session: Quickshell.env("SHINYSHELL_GREETER_SESSION")
  readonly property string user: Quickshell.env("SHINYSHELL_GREETER_USER")

  settings.watchFiles: isDev

  Greeter {
    session: root.session
    user: root.user
  }

  Component.onCompleted: {
    if (!root.user || !root.session) {
      console.error("No user or session found, greeter will not function properly");
    }
  }
}
