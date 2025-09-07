pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.Widgets
import qs.Config
import qs.Services

ShinyRectangle {
  id: root

  required property real leftOffset
  required property real rightOffset

  implicitHeight: 48
  color: Config.appearance.color.bgPrimary

  component Pill: Item {
    default property alias content: contentLayout.children

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.topMargin: 6
    anchors.bottomMargin: 6
    implicitWidth: contentLayout.width + 24

    ShinyRectangle {
      anchors.fill: parent
      color: Config.appearance.color.bgSecondary
      radius: Config.appearance.rounding.lg
    }

    RowLayout {
      id: contentLayout

      anchors.centerIn: parent
    }
  }

  Pill {
    anchors.horizontalCenter: parent.horizontalCenter

    ShinyText {
      id: text

      text: "Enter your password to unlock"
    }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: root.leftOffset
    anchors.rightMargin: root.rightOffset

    Loader {
      active: Weather.isAvailable
      anchors.fill: parent

      sourceComponent: Item {
        anchors.fill: parent

        Pill {
          anchors.left: parent.left
          anchors.leftMargin: 8

          Icon {
            icon: Weather.current.icon
            fill: 1
            font.pointSize: Config.appearance.font.size.xl
          }

          ShinyText {
            text: Weather.current.formattedTemperature
          }
        }
      }
    }

    Loader {
      active: Battery.isAvailable
      anchors.fill: parent

      sourceComponent: Item {
        anchors.fill: parent

        ShinyClippingRectangle {
          id: batteryPill

          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          anchors.topMargin: 6
          anchors.bottomMargin: 6
          anchors.rightMargin: 8
          implicitWidth: 100
          color: Config.appearance.color.bgSecondary
          radius: Config.appearance.rounding.lg

          RowLayout {
            anchors.centerIn: parent
            spacing: 4

            Icon {
              icon: Battery.icon
              fill: 1
              font.pointSize: Config.appearance.font.size.xl
            }

            ShinyText {
              text: Battery.formattedPercentage
            }
          }

          ShinyRectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            clip: true
            width: batteryPill.width * Battery.percentage
            color: Battery.isLow ? Config.appearance.color.bgError : Config.appearance.color.fgPrimary

            Behavior on width {
              NumberAnimation {
                duration: Config.appearance.anim.durations.md
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Config.appearance.anim.curves.standard
              }
            }

            RowLayout {
              // Simulate centering inside batteryPill
              x: (batteryPill.width - width) / 2
              y: (batteryPill.height - height) / 2
              spacing: 4

              Icon {
                icon: Battery.icon
                fill: 1
                color: Config.appearance.color.bgSecondary
                font.pointSize: Config.appearance.font.size.xl
              }

              ShinyText {
                text: Battery.formattedPercentage
                color: Config.appearance.color.bgSecondary
              }
            }
          }
        }
      }
    }
  }
}
