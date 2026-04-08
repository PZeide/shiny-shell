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

    FlexboxLayout {
      anchors.centerIn: parent
      gap: Config.appearance.spacing.sm

      ShinyButton {
        id: leftButton
        text: "Placement: LEFT"

        ShinyTooltip {
          visible: leftButton.hovered
          text: "This is a tooltip"
          placement: ShinyTooltip.Placement.Left
        }
      }

      ShinyButton {
        id: rightButton
        text: "Placement: RIGHT"

        ShinyTooltip {
          visible: rightButton.hovered
          text: "This is a tooltip"
          placement: ShinyTooltip.Placement.Right
        }
      }

      ShinyButton {
        id: topButton
        text: "Placement: TOP"

        ShinyTooltip {
          visible: topButton.hovered
          text: "This is a tooltip"
          placement: ShinyTooltip.Placement.Top
        }
      }

      ShinyButton {
        id: bottomButton
        text: "Placement: BOTTOM"

        ShinyTooltip {
          visible: bottomButton.hovered
          text: "This is a tooltip"
          placement: ShinyTooltip.Placement.Bottom
        }
      }
    }
  }
}
