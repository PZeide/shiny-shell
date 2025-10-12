pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.utils

JsonObject {
  property bool enabled: true
  property string path: Paths.assetPath("images/default_wallpaper.jpg")
  property string horizontalAlignement: "center"
  property string verticalAlignement: "top"
  property bool foreground: true
  property string customForegroundPath
}
