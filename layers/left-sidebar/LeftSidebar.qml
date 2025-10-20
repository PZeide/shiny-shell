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

      screen: modelData

      LazyLoader {
        activeAsync: layer.opened

        ShinyWindow {
          id: window

          name: "overview"
          screen: layer.screen
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

            onCleared: layer.closeLayer()
          }
        }
      }
    }
  }

  IpcHandler {
    id: ipc

    target: "left-sidebar"

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
    name: "left-sidebar-open"
    description: "Open left sidebar"
    onPressed: ipc.open()
  }

  ShinyShortcut {
    name: "left-sidebar-close"
    description: "Close left sidebar"
    onPressed: ipc.close()
  }

  ShinyShortcut {
    name: "left-sidebar-toggle"
    description: "Toggle left sidebar"
    onPressed: ipc.toggle()
  }
}
