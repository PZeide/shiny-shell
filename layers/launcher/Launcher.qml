pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components

Item {
  id: root

  function getActive(): ShinyLayerWrapper {
    return variant.instances.find(instance => instance.screen.name === Hyprland.focusedMonitor?.name);
  }

  Variants {
    id: variant
    model: Quickshell.screens

    delegate: ShinyLayerWrapper {
      id: layer

      required property ShellScreen modelData

      property string input: ""
      property int selectedItemIndex: 0

      screen: modelData

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
        layer.closeLayer();
      }

      LauncherBackend {
        id: backend
        input: layer.input

        onResultChanged: layer.selectedItemIndex = 0
      }

      LazyLoader {
        activeAsync: layer.opened

        ShinyWindow {
          id: window
          name: "launcher"
          screen: layer.screen
          anchors.bottom: true
          implicitWidth: layer.screen.width * 0.35
          implicitHeight: layer.screen.height
          exclusionMode: ExclusionMode.Ignore
          WlrLayershell.layer: WlrLayer.Overlay
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

          mask: Region {
            item: drawer
          }

          Component.onCompleted: {
            layer.input = "";
            layer.selectedItemIndex = 0;
          }

          HyprlandFocusGrab {
            id: grab
            active: true
            windows: [window]

            onCleared: layer.closeLayer()
          }

          LauncherDrawer {
            id: drawer
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height + layer.animationFactor * (8 + height)
            items: backend.result
            selectedIndex: layer.selectedItemIndex

            onInputChanged: layer.input = input
            onItemClicked: index => layer.invokeElement(index)
            onItemEntered: index => layer.selectedItemIndex = index
            Keys.onEscapePressed: layer.closeLayer()
            Keys.onReturnPressed: layer.invokeElement(layer.selectedItemIndex)
            Keys.onUpPressed: layer.tryDecrementSelectedIndex()
            Keys.onDownPressed: layer.tryIncrementSelectedIndex()
            Keys.onTabPressed: layer.tryIncrementSelectedIndex(true)
          }
        }
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "launcher"

    function toggle(): string {
      const layer = root.getActive();
      if (!layer)
        return "unavailable";

      layer.toggleLayer();
      return "ok";
    }

    function open(): string {
      const layer = root.getActive();
      if (!layer)
        return "unavailable";

      layer.openLayer();
      return "ok";
    }

    function close(): string {
      const layer = root.getActive();
      if (!layer)
        return "unavailable";

      layer.closeLayer();
      return "ok";
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
