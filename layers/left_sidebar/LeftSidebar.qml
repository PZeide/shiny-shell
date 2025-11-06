pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.containers
import qs.components.misc
import qs.components.effects
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

          name: "left-sidebar"
          screen: layer.screen
          anchors.top: true
          margins.top: Config.bar.height + Config.appearance.spacing.xs - elevation.size
          anchors.left: true
          implicitWidth: drawer.implicitWidth + Config.appearance.spacing.xs + elevation.size * 2
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

          LeftSidebarDrawer {
            id: drawer

            implicitWidth: window.screen.width * 0.25
            implicitHeight: window.screen.height - Config.bar.height - Config.appearance.spacing.xs * 2
            anchors.left: parent.left
            anchors.leftMargin: -implicitWidth + layer.animationFactor * (Config.appearance.spacing.xs + implicitWidth)
            anchors.top: parent.top
            anchors.topMargin: elevation.size
            focus: true

            Keys.onEscapePressed: layer.closeLayer()
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
