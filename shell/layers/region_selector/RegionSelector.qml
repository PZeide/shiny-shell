pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.misc
import qs.components.containers
import qs.layers.region_selector
import qs.utils.animations

ShinyLayerAnimationHelper {
  id: root

  property var currentRequest: null
  property real layerOpacity: 0

  function process(request: var) {
    if (root.currentRequest) {
      console.warn("Cannot process new request, current request is still pending");
      return;
    }

    root.currentRequest = request;
    openLayer();
  }

  onStateChanged: state => {
    if (state === "closed") {
      if (root.currentRequest !== null && !root.currentRequest.resolved) {
        console.warn("Selector closed but request has not been resolved");
        root.currentRequest.callback(null);
      }

      root.currentRequest = null;

      if (RegionSelection.requests.length > 0) {
        root.process(RegionSelection.pump());
      }
    }
  }

  enter: Transition {
    EffectNumberAnimation {
      target: root
      property: "layerOpacity"
      from: root.layerOpacity
      to: 0.55
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

  Connections {
    target: RegionSelection

    function onRequestReceived() {
      if (root.currentRequest === null) {
        root.process(RegionSelection.pump());
      }
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
          freeze: root.currentRequest?.options?.freeze ?? false
          hintWindows: root.currentRequest?.options?.hintWindows ?? true
          hintLayers: root.currentRequest?.options?.hintLayers ?? true

          onSelected: region => {
            root.closeLayer();
            if (!root.currentRequest) {
              console.warn("Selection completed, but no current request");
              return;
            }

            root.currentRequest.callback(region);
            root.currentRequest.resolved = true;
          }

          onCancelled: {
            root.closeLayer();
            if (!root.currentRequest) {
              console.warn("Selection cancelled, but no current request");
              return;
            }

            root.currentRequest.callback(null);
            root.currentRequest.resolved = true;
          }
        }
      }
    }
  }
}
