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
      gap: Config.appearance.spacing.lg
      direction: FlexboxLayout.Column
      alignItems: FlexboxLayout.AlignCenter

      ShinyTextField {
        sIcon.name: "search"
        placeholderText: "Search"
      }

      ShinyTextField {
        placeholderText: "Type your name"
      }

      ShinyTextField {
        enabled: false
      }

      ShinyButton {
        variant: ShinyButton.Variant.Secondary
        text: "Unfocus"

        onClicked: focus = true
      }
    }
  }
}
