pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Widgets

ShinyWindow {
  id: root

  required property ShellScreen modelData

  name: "wallpaper"
  screen: modelData
  anchors.bottom: true
  anchors.left: true
  anchors.right: true
  anchors.top: true
  focusable: false
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Background

  WallpaperImage {
    id: wallpaper

    asynchronous: true

    onStatusChanged: {
      if (wallpaper.status === Image.Ready) {
        console.info("Wallpaper successfully loaded");
      } else if (wallpaper.status === Image.Error) {
        console.error("Failed to load wallpaper, make sure that the path configured is correct");
      }
    }
  }
}
