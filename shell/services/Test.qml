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
            implicitWidth: 180
            implicitHeight: 40
            text: row.modelData.name + " Enabled"
            variant: row.modelData.value
            enabled: true
          }

          ShinyButton {
            implicitWidth: 180
            implicitHeight: 40
            text: row.modelData.name + " Disabled"
            variant: row.modelData.value
            enabled: false
          }

          ShinyButton {
            implicitWidth: 180
            implicitHeight: 40
            text: row.modelData.name + " Icon"
            iconName: "star"
            variant: row.modelData.value
            enabled: true
          }

          ShinyButton {
            implicitWidth: 40
            implicitHeight: 40
            iconName: "star"
            variant: row.modelData.value
            enabled: true
          }
        }
      }

      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 10

        ShinyButton {
          id: tooltipButton
          Layout.alignment: Qt.AlignHCenter
          implicitWidth: 180
          implicitHeight: 40
          text: "Show tooltip"

          ShinyTooltip {
            visible: tooltipButton.hovered
            text: "This is a tooltip"
          }
        }

        ShinyButton {
          Layout.alignment: Qt.AlignHCenter
          implicitWidth: 180
          implicitHeight: 40
          text: "Open menu"

          onClicked: menu.open()

          ShinyMenu {
            id: menu
            title: "Menu!"
            x: parent.width / 2 - width / 2
            y: parent.height + Config.appearance.spacing.xxs

            ShinyMenuItem {
              text: "Item"
            }

            ShinyMenuItem {
              text: "Item with icon"
              iconName: "light"
            }

            ShinyMenuItem {
              text: "Item disabled"
              enabled: false
            }

            ShinyMenuItem {
              text: "Item loooooooooooooooooooooooooooooooooooooong"
            }

            ShinyMenu {
              title: "Nested menu"

              ShinyMenuItem {
                text: "Nested item 1"
              }

              ShinyMenuItem {
                text: "Nested item 2"
              }
            }

            ShinyMenuItem {
              text: "Item checkable disabled"
              checkable: true
              checked: true
              enabled: false
            }

            ShinyMenuItem {
              text: "Item checkable"
              checkable: true
            }
          }
        }
      }
    }
  }
}
