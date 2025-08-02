pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

Image {
  anchors.fill: parent
  antialiasing: true
  cache: true
  mipmap: true
  retainWhileLoading: true
  fillMode: Image.PreserveAspectCrop
  horizontalAlignment: Config.wallpaper.horizontalAlignement
  verticalAlignment: Config.wallpaper.verticalAlignement
}
