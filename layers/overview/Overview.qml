pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.widgets

ShinyAnimatedLayer {
  id: root

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
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

      mask: Region {
        item: drawer
      }

      HyprlandFocusGrab {
        id: grab

        active: true
        windows: [window]
        onCleared: root.closeLayer()
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
    id: ipc

    target: "overview"

    function toggle() {
      root.toggleLayer();
    }

    function open() {
      root.openLayer();
    }

    function close() {
      root.closeLayer();
    }
  }

  ShinyShortcut {
    name: "overview-open"
    description: "Open overview"
    onPressed: ipc.open()
  }

  ShinyShortcut {
    name: "overview-close"
    description: "Close overview"
    onPressed: ipc.close()
  }

  ShinyShortcut {
    name: "overview-toggle"
    description: "Toggle overview"
    onPressed: ipc.toggle()
  }
}
