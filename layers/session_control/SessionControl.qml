pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.effects
import qs.components.containers
import qs.components.misc
import qs.config

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
          name: "session-control"
          screen: layer.screen
          anchors.right: true
          implicitWidth: drawer.implicitWidth + Config.appearance.padding.sm + elevation.size * 2
          implicitHeight: drawer.implicitHeight + elevation.size * 2
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

          SessionControlDrawer {
            id: drawer
            anchors.right: parent.right
            anchors.rightMargin: -implicitWidth + layer.animationFactor * (Config.appearance.padding.sm + implicitWidth)
            anchors.verticalCenter: parent.verticalCenter

            onShouldClose: layer.closeLayer()
            Keys.onEscapePressed: layer.closeLayer()
          }
        }
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "session-control"

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
    name: "session-control-open"
    description: "Open session control"
    onPressed: ipc.open()
  }

  ShinyShortcut {
    name: "session-control-close"
    description: "Close session control"
    onPressed: ipc.close()
  }

  ShinyShortcut {
    name: "session-control-toggle"
    description: "Toggle session control"
    onPressed: ipc.toggle()
  }
}
