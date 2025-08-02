import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property string path: "/home/thibaud/wallpaper.jpg"
  property int horizontalAlignement: Image.AlignHCenter
  property int verticalAlignement: Image.Top
  property bool foreground: true
  property string customForegroundPath
}
