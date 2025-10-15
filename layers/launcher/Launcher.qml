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

  property string input: ""
  property int selectedItemIndex: 0

  function tryDecrementSelectedIndex(shouldLoop = false) {
    if (selectedItemIndex > 0) {
      selectedItemIndex--;
    } else if (shouldLoop) {
      selectedItemIndex = backend.result.rowCount() - 1;
    }
  }

  function tryIncrementSelectedIndex(shouldLoop = false) {
    if (backend.result.rowCount() > selectedItemIndex + 1) {
      selectedItemIndex++;
    } else if (shouldLoop) {
      selectedItemIndex = 0;
    }
  }

  function invokeElement(index: int) {
    if (backend.result.rowCount() <= index)
      return;

    backend.result.invoke(index);
    root.closeLayer();
  }

  LauncherBackend {
    id: backend

    input: root.input

    onResultChanged: root.selectedItemIndex = 0
  }

  LazyLoader {
    activeAsync: root.opened

    ShinyWindow {
      id: window

      name: "launcher"
      screen: root.screen
      anchors.bottom: true
      implicitWidth: root.screen.width * 0.35
      implicitHeight: root.screen.height
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

      Component.onCompleted: {
        root.input = "";
        root.selectedItemIndex = 0;
      }

      HyprlandFocusGrab {
        id: grab

        active: true
        windows: [window]
        onCleared: root.closeLayer()
      }

      Connections {
        target: grab
        function onActiveChanged() {
          if (!grab.active)
            root.closeLayer();
        }
      }

      LauncherDrawer {
        id: drawer

        anchors.bottom: parent.bottom
        anchors.bottomMargin: -height + root.animationFactor * (8 + height)
        items: backend.result
        selectedIndex: root.selectedItemIndex

        onInputChanged: root.input = input
        onItemClicked: index => root.invokeElement(index)
        onItemEntered: index => root.selectedItemIndex = index
        Keys.onEscapePressed: root.closeLayer()
        Keys.onReturnPressed: root.invokeElement(root.selectedItemIndex)
        Keys.onUpPressed: root.tryDecrementSelectedIndex()
        Keys.onDownPressed: root.tryIncrementSelectedIndex()
        Keys.onTabPressed: root.tryIncrementSelectedIndex(true)
      }
    }
  }

  IpcHandler {
    id: ipc

    target: "launcher"

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
    name: "launcher-open"
    description: "Open launcher"
    onPressed: ipc.open()
  }

  ShinyShortcut {
    name: "launcher-close"
    description: "Close launcher"
    onPressed: ipc.close()
  }

  ShinyShortcut {
    name: "launcher-toggle"
    description: "Toggle launcher"
    onPressed: ipc.toggle()
  }
}
