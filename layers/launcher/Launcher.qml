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
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      Component.onCompleted: {
        root.input = "";
        root.selectedItemIndex = 0;
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

      LauncherDrawer {
        id: drawer

        anchors.bottom: parent.bottom
        anchors.bottomMargin: -height + root.animationFactor * (8 + height)
        items: backend.result
        selectedIndex: -root.selectedItemIndex

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
    target: "launcher"

    function toggle() {
      console.info("Received launcher toggle from IPC");
      root.toggleLayer();
    }

    function open() {
      console.info("Received launcher open from IPC");
      root.openLayer();
    }

    function close() {
      console.info("Received launcher close from IPC");
      root.closeLayer();
    }
  }
}
