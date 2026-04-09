pragma ComponentBehavior: Bound

import QtQuick
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
      anchors.centerIn: parent
      implicitWidth: 180
      implicitHeight: 40
      text: "Open menu"

      onClicked: menu.open()

      ShinyMenu {
        id: menu
        title: "Menu"
        x: parent.width / 2 - width / 2
        y: parent.height + Config.appearance.spacing.xxs

        ShinyMenuItem {
          text: "Item"
        }

        ShinyMenuItem {
          text: "Item with icon"
          sIcon.name: "tenancy"
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
