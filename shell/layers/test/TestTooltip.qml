pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components.controls

Variants {
  model: Quickshell.screens

  FloatingWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    color: Config.appearance.color.surface

    ShinyButton {
      id: tooltipButton
      anchors.centerIn: parent
      implicitWidth: 180
      implicitHeight: 40
      text: "Hover to show tooltip"

      ShinyTooltip {
        visible: tooltipButton.hovered
        text: "This is a tooltip"
      }
    }
  }
}
