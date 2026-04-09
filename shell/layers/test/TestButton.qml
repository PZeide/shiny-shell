pragma ComponentBehavior: Bound

import QtQuick
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

      property var buttonVariants: [
        {
          name: "Primary",
          value: ShinyButton.Variant.Primary
        },
        {
          name: "Secondary",
          value: ShinyButton.Variant.Secondary
        },
        {
          name: "Ghost",
          value: ShinyButton.Variant.Ghost
        },
        {
          name: "Danger",
          value: ShinyButton.Variant.Danger
        }
      ]

      Repeater {
        model: layout.buttonVariants

        delegate: RowLayout {
          id: row
          Layout.alignment: Qt.AlignHCenter
          spacing: 10

          required property var modelData

          ShinyButton {
            text: row.modelData.name + " Enabled"
            variant: row.modelData.value
            enabled: true
            font.weight: Font.Bold
          }

          ShinyButton {
            text: row.modelData.name + " Disabled"
            variant: row.modelData.value
            enabled: false
          }

          ShinyButton {
            text: row.modelData.name + " Checkable"
            variant: row.modelData.value
            enabled: true
            checkable: true
          }

          ShinyButton {
            text: row.modelData.name + " Icon"
            sIcon.name: "star"
            variant: row.modelData.value
            enabled: true
          }

          ShinyButton {
            display: ShinyButton.IconOnly
            sIcon.name: "star"
            variant: row.modelData.value
            enabled: true
          }

          ShinyButton {
            display: ShinyButton.TextUnderIcon
            text: row.modelData.name + " Vertical"
            sIcon.name: "star"
            variant: row.modelData.value
            enabled: true
          }
        }
      }
    }
  }
}
