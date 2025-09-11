pragma ComponentBehavior: Bound

import QtQuick
import qs.config

Image {
  anchors.fill: parent
  antialiasing: true
  cache: true
  mipmap: true
  retainWhileLoading: true
  layer.enabled: true
  fillMode: Image.PreserveAspectCrop
  source: Config.wallpaper.path

  horizontalAlignment: switch (Config.wallpaper.horizontalAlignement) {
  case "left":
    return Image.AlignLeft;
  case "right":
    return Image.AlignRight;
  case "center":
  default:
    return Image.AlignHCenter;
  }

  verticalAlignment: switch (Config.wallpaper.verticalAlignement) {
  case "top":
    return Image.AlignTop;
  case "bottom":
    return Image.AlignBottom;
  case "center":
  default:
    return Image.AlignVCenter;
  }
}
