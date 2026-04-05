pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.synchronizer
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.components.containers
import qs.components.misc
import qs.config
import qs.utils
import qs.utils.animations

Item {
  id: root

  function getActiveLayerHelper(): ShinyLayerAnimationHelper {
    return variant.instances.find(instance => instance.modelData.name === HyprCompositor.activeMonitor?.name);
  }

  Variants {
    id: variant
    model: Quickshell.screens

    delegate: ShinyLayerAnimationHelper {
      id: layerHelper

      required property ShellScreen modelData
      property real drawerOpacity: 0
      property real drawerScale: 0.75
      property real appearanceFactor: 0

      enter: Transition {
        EffectNumberAnimation {
          target: layerHelper
          property: "drawerOpacity"
          from: layerHelper.drawerOpacity
          to: 1
        }

        EffectNumberAnimation {
          target: layerHelper
          property: "drawerScale"
          from: layerHelper.drawerScale
          to: 1
        }

        EffectNumberAnimation {
          target: layerHelper
          property: "appearanceFactor"
          from: layerHelper.appearanceFactor
          to: 1
        }
      }

      exit: Transition {
        EffectNumberAnimation {
          target: layerHelper
          property: "drawerOpacity"
          from: layerHelper.drawerOpacity
          to: 0
        }

        EffectNumberAnimation {
          target: layerHelper
          property: "drawerScale"
          from: layerHelper.drawerScale
          to: 0.75
        }

        EffectNumberAnimation {
          target: layerHelper
          property: "appearanceFactor"
          from: layerHelper.appearanceFactor
          to: 0
        }
      }

      Loader {
        id: loader
        active: layerHelper.shown

        sourceComponent: ShinyWindow {
          id: window
          name: "overview"
          screen: layerHelper.modelData
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

            onCleared: layerHelper.closeLayer()
          }

          ShinyElevatedContainer {
            id: elevation
            target: drawer
            opacity: layerHelper.drawerOpacity
            scale: layerHelper.drawerScale
          }

          OverviewDrawer {
            id: drawer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -height + layerHelper.appearanceFactor * ((Config.appearance.spacing.xxl * 6) + height)
            screen: layerHelper.modelData
            opacity: layerHelper.drawerOpacity
            scale: layerHelper.drawerScale
            focus: true

            onShouldClose: layerHelper.closeLayer()
            Keys.onEscapePressed: layerHelper.closeLayer()
          }
        }
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "overview"

    function toggle(): string {
      const layerHelper = root.getActiveLayerHelper();
      if (!layerHelper)
        return Helpers.fail("unavailable");

      layerHelper.toggleLayer();
      return Helpers.success("ok");
    }

    function open(): string {
      const layerHelper = root.getActiveLayerHelper();
      if (!layerHelper)
        return Helpers.fail("unavailable");

      layerHelper.openLayer();
      return Helpers.success("ok");
    }

    function close(): string {
      const layerHelper = root.getActiveLayerHelper();
      if (!layerHelper)
        return Helpers.fail("unavailable");

      layerHelper.closeLayer();
      return Helpers.success("ok");
    }
  }
}
