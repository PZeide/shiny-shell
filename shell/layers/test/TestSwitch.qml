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

    ColumnLayout {
      id: layout
      anchors.centerIn: parent
      spacing: 30

      property var switchVariants: [
        {
          name: "Primary",
          value: ShinySwitch.Variant.Primary
        },
        {
          name: "Secondary",
          value: ShinySwitch.Variant.Secondary
        },
        {
          name: "Tertiary",
          value: ShinySwitch.Variant.Tertiary
        }
      ]

      Repeater {
        model: layout.switchVariants

        delegate: RowLayout {
          id: row
          Layout.alignment: Qt.AlignHCenter
          spacing: 10

          required property var modelData

          ShinySwitch {
            variant: row.modelData.value
            enabled: true
          }

          ShinySwitch {
            variant: row.modelData.value
            enabled: false
          }

          ShinySwitch {
            variant: row.modelData.value
            enabled: false
            checked: true
          }

          ShinySwitch {
            variant: row.modelData.value
            enabled: true
            sIcon.name: "home"
          }

          ShinySwitch {
            variant: row.modelData.value
            enabled: false
            sIcon.name: "home"
          }

          ShinySwitch {
            variant: row.modelData.value
            enabled: true
            sCheckedIcon.name: "check"
            sUncheckedIcon.name: "close"
          }
        }
      }
    }
  }
}
