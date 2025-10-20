pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.layers.bar.modules

Variants {
  model: Quickshell.screens

  ShinyWindow {
    id: root

    required property ShellScreen modelData

    name: "bar"
    screen: modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Config.bar.height
    color: Config.appearance.color.bgPrimary
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Row {
      height: parent.height
      anchors.left: parent.left
      anchors.leftMargin: 7
      spacing: Config.bar.moduleSpacing

      HostIcon {}
      DateTime {}
    }

    Row {
      height: parent.height
      anchors.verticalCenter: parent.verticalCenter
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Config.bar.moduleSpacing

      Workspaces {
        screen: root.screen
      }
    }

    Row {
      height: parent.height
      anchors.right: parent.right
      anchors.rightMargin: 7
      spacing: Config.bar.moduleSpacing
    }
  }
}
