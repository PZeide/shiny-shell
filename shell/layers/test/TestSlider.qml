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
      gap: Config.appearance.spacing.xxl
      direction: FlexboxLayout.Column
      alignItems: FlexboxLayout.AlignCenter

      ShinySubtleSlider {
        value: 0.5
      }

      ShinySubtleSlider {
        value: 0.2
        showTooltip: true
        tooltipPlacement: ShinyTooltip.Placement.Bottom
      }

      ShinySubtleSlider {
        enabled: false
        value: 0.8
      }

      ShinySubtleSlider {
        variant: ShinySubtleSlider.Variant.Secondary
        value: 0.3
      }

      ShinySubtleSlider {
        variant: ShinySubtleSlider.Variant.Secondary
        enabled: false
        value: 0.9
      }
    }
  }
}
