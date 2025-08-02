pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Widgets
import qs.Config
import qs.Layers.Bar.Modules

Item {
  id: root

  required property ShellScreen screen

  ShinyWindow {
    name: "bar"
    screen: root.screen
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Config.bar.height + Config.bar.topMargin + Config.bar.bottomMargin

    Item {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.topMargin: Config.bar.topMargin
      anchors.bottomMargin: Config.bar.bottomMargin
      anchors.leftMargin: Config.bar.horizontalMargin
      anchors.rightMargin: Config.bar.horizontalMargin
      implicitHeight: Config.bar.height

      ShinyRectangle {
        width: parent.width
        height: parent.height
        color: Config.appearance.color.bgPrimary
        radius: Config.appearance.rounding.lg

        Row {
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: 7
          spacing: Config.bar.moduleSpacing

          OsIcon {}
        }

        Row {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Config.bar.moduleSpacing

          Time {
            id: timeModule
          }
        }

        Row {
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          anchors.rightMargin: 7
          spacing: Config.bar.moduleSpacing
        }
      }
    }
  }
}
