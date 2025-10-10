pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property string path: "/home/thibaud/wallpaper.png"
  property string horizontalAlignement: "center"
  property string verticalAlignement: "top"
  property bool foreground: true
  property string customForegroundPath
}
