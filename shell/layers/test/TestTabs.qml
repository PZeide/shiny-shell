pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.components.controls

Variants {
  model: Quickshell.screens

  FloatingWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    color: Config.appearance.color.surface

    ShinyTabBar {
      id: tabBar
      anchors.top: parent.top
      anchors.topMargin: Config.appearance.spacing.lg
      anchors.horizontalCenter: parent.horizontalCenter

      ShinyTabButton {
        text: "Home"
        sIcon.name: "home"
      }

      ShinyTabButton {
        text: "Store"
      }

      ShinyTabButton {
        text: "Shinyyyyyyyyyyyyy"
      }
    }

    ShinyClippingRectangle {
      anchors.top: tabBar.bottom
      anchors.topMargin: Config.appearance.spacing.lg
      anchors.horizontalCenter: parent.horizontalCenter
      implicitWidth: 500
      implicitHeight: 300

      SwipeView {
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        interactive: false

        Rectangle {
          color: "red"
        }

        Rectangle {
          color: "green"
        }

        Rectangle {
          color: "blue"
        }
      }
    }
  }
}
