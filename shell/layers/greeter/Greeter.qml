pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.containers

Item {
  id: root

  required property string session
  required property string user

  GreeterContext {
    id: context
    session: root.session
    user: root.user
  }

  Variants {
    model: Quickshell.screens

    ShinyWindow {
      required property ShellScreen modelData

      name: "greeter"
      screen: modelData
      anchors.bottom: true
      anchors.left: true
      anchors.right: true
      anchors.top: true
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      GreeterSurface {
        id: surface
        context: context
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.BlankCursor
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        onPressed: event => event.accepted = true
        onReleased: event => event.accepted = true
        onPositionChanged: event => event.accepted = true
      }
    }
  }
}
