pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.widgets
import qs.config
import qs.layers.bar.modules

ShinyWindow {
  id: root

  required property ShellScreen screen

  name: "bar"
  screen: root.screen
  anchors.top: true
  anchors.left: true
  anchors.right: true
  implicitHeight: Config.bar.height
  color: Config.appearance.color.bgPrimary
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  Row {
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: 7
    spacing: Config.bar.moduleSpacing

    HostIcon {}
  }

  Row {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Config.bar.moduleSpacing
  }

  Row {
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.rightMargin: 7
    spacing: Config.bar.moduleSpacing
  }
}
