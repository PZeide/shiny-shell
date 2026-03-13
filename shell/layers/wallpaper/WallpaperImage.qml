pragma ComponentBehavior: Bound

import QtQuick
import qs.config

Image {
  required property int imageWidth
  required property int imageHeight

  cache: true
  fillMode: Image.PreserveAspectCrop
  mipmap: true
  retainWhileLoading: true
  source: Config.wallpaper.path
  sourceSize: Qt.size(imageWidth, imageHeight)

  horizontalAlignment: switch (Config.wallpaper.horizontalAlignement) {
  case "left":
    return Image.AlignLeft;
  case "right":
    return Image.AlignRight;
  default:
    return Image.AlignHCenter;
  }

  verticalAlignment: switch (Config.wallpaper.verticalAlignement) {
  case "top":
    return Image.AlignTop;
  case "bottom":
    return Image.AlignBottom;
  default:
    return Image.AlignVCenter;
  }
}
