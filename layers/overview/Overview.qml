pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.effects
import qs.components.containers
import qs.components.misc

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
        active: layer.shown

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

          ShinyElevatedLayer {
            id: elevation
            target: drawer
          }

          OverviewDrawer {
            id: drawer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -implicitHeight + layer.animationFactor * (80 + implicitHeight)
            focus: true
            screen: layer.screen

            Keys.onEscapePressed: layer.closeLayer()
            onShouldClose: layer.closeLayer()
          }
        }
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "overview"

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
