pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.containers

Variants {
  model: Quickshell.screens

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
      anchors.fill: parent
      imageWidth: root.modelData.width
      imageHeight: root.modelData.height

      onStatusChanged: {
        if (wallpaper.status === Image.Ready) {
          console.info("Wallpaper successfully loaded");
        } else if (wallpaper.status === Image.Error) {
          console.error("Failed to load wallpaper, make sure that the path configured is correct");
        }
      }
    }
  }
}
