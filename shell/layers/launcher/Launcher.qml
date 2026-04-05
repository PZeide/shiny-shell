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

      onShownChanged: backend.reset()

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

      LauncherBackend {
        id: backend
      }

      Loader {
        id: loader
        active: layerHelper.shown

        sourceComponent: ShinyWindow {
          id: window
          name: "launcher"
          screen: layerHelper.modelData
          anchors.bottom: true
          implicitWidth: layerHelper.modelData.width
          implicitHeight: layerHelper.modelData.height // Stretch to whole screen to avoid flickering when drawer's height changes
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

          LauncherDrawer {
            id: drawer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height + layerHelper.appearanceFactor * (Config.appearance.spacing.sm + height)
            implicitWidth: layerHelper.modelData.width * 0.35
            items: backend.result
            opacity: layerHelper.drawerOpacity
            scale: layerHelper.drawerScale

            Synchronizer on input {
              sourceObject: backend
              sourceProperty: "input"
            }

            Synchronizer on selectedIndex {
              sourceObject: backend
              sourceProperty: "selectedItemIndex"
            }

            onItemClicked: index => {
              backend.invokeElement(index);
              layerHelper.closeLayer();
            }

            Keys.onReturnPressed: {
              backend.invokeElement(backend.selectedItemIndex);
              layerHelper.closeLayer();
            }

            Keys.onEscapePressed: layerHelper.closeLayer()
            Keys.onUpPressed: backend.tryDecrementSelectedIndex()
            Keys.onDownPressed: backend.tryIncrementSelectedIndex()
            Keys.onTabPressed: backend.tryIncrementSelectedIndex(true)
          }
        }
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "launcher"

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
