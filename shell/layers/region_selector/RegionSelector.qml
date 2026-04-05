pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.components.misc
import qs.components.containers
import qs.utils
import qs.utils.animations

ShinyLayerAnimationHelper {
  id: root

  property real layerOpacity: 0

  enter: Transition {
    EffectNumberAnimation {
      target: root
      property: "layerOpacity"
      from: root.layerOpacity
      to: 0.45
    }
  }

  exit: Transition {
    EffectNumberAnimation {
      target: root
      property: "layerOpacity"
      from: root.layerOpacity
      to: 0
    }
  }

  Loader {
    active: root.shown

    sourceComponent: Variants {
      id: variant
      model: Quickshell.screens

      delegate: ShinyWindow {
        id: window

        required property ShellScreen modelData

        name: "region-selector"
        screen: modelData
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitWidth: screen.width
        implicitHeight: screen.height
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        ShortcutInhibitor {
          window: window
          enabled: true
        }

        RegionSelectorLayer {
          anchors.fill: parent
          opacity: root.layerOpacity
          screen: window.modelData
          freeze: false
          snapWindows: false
          snapLayers: false

          onSelected: root.closeLayer()
          onCancelled: root.closeLayer()
        }
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "region-selector"

    function toggle(): string {
      root.toggleLayer();
      return Helpers.success("ok");
    }

    function open(): string {
      root.openLayer();
      return Helpers.success("ok");
    }

    function close(): string {
      root.closeLayer();
      return Helpers.success("ok");
    }
  }
}
