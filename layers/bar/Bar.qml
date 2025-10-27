pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Shiny.DBus
import qs.components
import qs.config
import qs.layers.bar.modules

Variants {
  model: Quickshell.screens

  ShinyWindow {
    id: root

    required property ShellScreen modelData

    readonly property int moduleSpacing: Config.appearance.spacing.sm

    name: "bar"
    screen: modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Config.bar.height
    color: Config.appearance.color.surface
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Row {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.leftMargin: Config.appearance.spacing.sm
      spacing: root.moduleSpacing

      HostModule {}
      ClockModule {}
      WeatherModule {}
    }

    Row {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: root.moduleSpacing

      WorkspacesModule {
        screen: root.screen
      }
    }

    Row {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.rightMargin: Config.appearance.spacing.sm
      spacing: root.moduleSpacing

      BatteryModule {}
    }
  }
}
