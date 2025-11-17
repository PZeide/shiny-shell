pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.components.containers
import qs.services
import qs.config
import qs.utils.animations

ShinyLayerWrapper {
  id: layer

  Loader {
    active: layer.shown

    sourceComponent: ShinyWindow {
      name: "notification-popus"
      screen: layer.screen
      anchors.top: true
      anchors.right: true
      implicitWidth: drawer.implicitWidth
      implicitHeight: drawer.implicitHeight
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay

      mask: Region {
        item: drawer
      }

      ShinyRectangle {
        id: drawer
        implicitWidth: 300
        implicitHeight: 500
        anchors.top: parent.top
        anchors.right: parent.right
        color: "red"

        ListView {
          id: view

          anchors.fill: parent
          model: Notifications.all.filter(n => n.popup)

          remove: Transition {
            animations: [
              StandardOutNumberAnimation {
                property: "x"
                to: view.width + 20
              },
              StandardOutNumberAnimation {
                property: "opacity"
                to: 0
              }
            ]
          }

          delegate: Text {
            required property Notifications.WrappedNotification modelData
            text: modelData.summary
          }
        }
      }
    }
  }
}
