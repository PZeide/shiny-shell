pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components

Variants {
  model: Quickshell.screens

  Item {
    id: root

    required property ShellScreen modelData

    ShinyWindow {
      name: "corner-topleft"
      screen: root.modelData
      anchors.top: true
      anchors.left: true
      implicitWidth: cornerTopLeft.implicitWidth
      implicitHeight: cornerTopLeft.implicitHeight
      exclusionMode: ExclusionMode.Normal
      WlrLayershell.layer: WlrLayer.Top

      RoundedCorner {
        id: cornerTopLeft
        type: RoundedCorner.Type.TopLeft
      }
    }

    ShinyWindow {
      name: "corner-topright"
      screen: root.modelData
      anchors.top: true
      anchors.right: true
      implicitWidth: cornerTopRight.implicitWidth
      implicitHeight: cornerTopRight.implicitHeight
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Top

      RoundedCorner {
        id: cornerTopRight
        type: RoundedCorner.Type.TopRight
      }
    }

    ShinyWindow {
      name: "corner-bottomleft"
      screen: root.modelData
      anchors.bottom: true
      anchors.left: true
      implicitWidth: cornerBottomLeft.implicitWidth
      implicitHeight: cornerBottomLeft.implicitHeight
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Top

      RoundedCorner {
        id: cornerBottomLeft
        type: RoundedCorner.Type.BottomLeft
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

      RoundedCorner {
        id: cornerBottomRight
        type: RoundedCorner.Type.BottomRight
      }
    }
  }
}
