pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components.containers
import qs.layers.bar.modules as BarModules

Variants {
  model: Quickshell.screens

  Item {
    id: root

    required property ShellScreen modelData

    ShinyWindow {
      id: bar

      readonly property int moduleSpacing: Config.appearance.spacing.sm

      name: "bar"
      screen: root.modelData
      anchors.top: true
      anchors.bottom: true
      anchors.left: true
      implicitWidth: Config.bar.size
      color: Config.appearance.color.surface
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

      Item {
        anchors.fill: parent
        anchors.leftMargin: Config.appearance.spacing.xs
        anchors.rightMargin: Config.appearance.spacing.xs
        anchors.topMargin: Config.appearance.spacing.xxl * 2
        anchors.bottomMargin: Config.appearance.spacing.xxl * 2

        Column {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          spacing: bar.moduleSpacing

          Repeater {
            model: Config.bar.topModules
            delegate: delegateChooser
          }
        }

        Column {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: bar.moduleSpacing

          Repeater {
            model: Config.bar.centerModules
            delegate: delegateChooser
          }
        }

        Column {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          spacing: bar.moduleSpacing

          Repeater {
            model: Config.bar.bottomModules
            delegate: delegateChooser
          }
        }

        DelegateChooser {
          id: delegateChooser

          DelegateChoice {
            roleValue: "clock"
            delegate: BarModules.Clock {}
          }

          DelegateChoice {
            roleValue: "screen-recorder"
            delegate: BarModules.ScreenRecorder {}
          }

          /*DelegateChoice {
            roleValue: "tray"
            delegate: BarModules.Tray {}
            }*/

          DelegateChoice {
            roleValue: "workspaces"
            delegate: BarModules.Workspaces {
              screen: root.modelData
            }
          }
        }
      }
    }

    ShinyWindow {
      name: "corner-topleft"
      screen: root.modelData
      anchors.top: true
      anchors.left: true
      implicitWidth: cornerTopLeft.implicitWidth
      implicitHeight: cornerTopLeft.implicitHeight
      exclusionMode: ExclusionMode.Normal
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      ScreenCorner {
        id: cornerTopLeft
        type: ScreenCorner.Type.TopLeft
      }
    }

    ShinyWindow {
      name: "corner-topright"
      screen: root.modelData
      anchors.top: true
      anchors.right: true
      implicitWidth: cornerTopRight.implicitWidth
      implicitHeight: cornerTopRight.implicitHeight
      exclusionMode: ExclusionMode.Normal
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      ScreenCorner {
        id: cornerTopRight
        type: ScreenCorner.Type.TopRight
      }
    }

    ShinyWindow {
      name: "corner-bottomleft"
      screen: root.modelData
      anchors.bottom: true
      anchors.left: true
      implicitWidth: cornerBottomLeft.implicitWidth
      implicitHeight: cornerBottomLeft.implicitHeight
      exclusionMode: ExclusionMode.Normal
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      ScreenCorner {
        id: cornerBottomLeft
        type: ScreenCorner.Type.BottomLeft
      }
    }

    ShinyWindow {
      name: "corner-bottomright"
      screen: root.modelData
      anchors.bottom: true
      anchors.right: true
      implicitWidth: cornerBottomRight.implicitWidth
      implicitHeight: cornerBottomRight.implicitHeight
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      ScreenCorner {
        id: cornerBottomRight
        type: ScreenCorner.Type.BottomRight
      }
    }
  }
}
