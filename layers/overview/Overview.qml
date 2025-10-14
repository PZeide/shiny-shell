pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.widgets
import qs.utils.animations

ShinyAnimatedLayer {
  id: root

  property real animationFactor: 0

  animationIn: ExpressiveNumberAnimation {
    target: root
    property: "animationFactor"
    from: 0
    to: 1
  }

  animationOut: ExpressiveNumberAnimation {
    target: root
    property: "animationFactor"
    from: 1
    to: 0
  }

  LazyLoader {
    activeAsync: root.opened

    ShinyWindow {
      id: window

      name: "overview"
      screen: root.screen
      anchors.top: true
      implicitWidth: screen.width
      implicitHeight: screen.height
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      mask: Region {
        item: drawer
      }

      HyprlandFocusGrab {
        id: grab

        active: true
        windows: [window]
      }

      Connections {
        target: grab
        function onActiveChanged() {
          if (!grab.active)
            root.closeLayer();
        }
      }

      OverviewDrawer {
        id: drawer

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -implicitHeight + root.animationFactor * (80 + implicitHeight)
        focus: true
        screen: root.screen

        Keys.onEscapePressed: root.closeLayer()
        onShouldClose: root.closeLayer()
      }
    }
  }

  IpcHandler {
    target: "overview"

    function toggle() {
      console.info("Received overview toggle from IPC");
      root.toggleLayer();
    }

    function open() {
      console.info("Received overview open from IPC");
      root.openLayer();
    }

    function close() {
      console.info("Received overview close from IPC");
      root.closeLayer();
    }
  }
}
