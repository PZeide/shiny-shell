pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland

QtObject {
  required property string namespace
  required property HyprlandMonitor monitor
  required property int level
  required property int x
  required property int y
  required property int width
  required property int height
  required property var lastIpcObject
}
