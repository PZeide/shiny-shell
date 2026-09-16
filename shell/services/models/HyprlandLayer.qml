pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland

QtObject {
  required property var lastIpcObject
  required property string monitorName
  required property HyprlandMonitor monitor
  required property int level

  readonly property string address: String(lastIpcObject.address)
  readonly property string namespace: lastIpcObject.namespace ?? ""
  readonly property int x: lastIpcObject.x ?? 0
  readonly property int y: lastIpcObject.y ?? 0
  readonly property int width: lastIpcObject.w ?? 0
  readonly property int height: lastIpcObject.h ?? 0
}
