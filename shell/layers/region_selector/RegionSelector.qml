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
  property var pendingResult: null
  property bool pendingCancelled: true
  property bool completionPending: false
  property real layerOpacity: 0

  function process(request: var) {
    if (root.currentRequest) {
      console.warn("Cannot process new request, current request is still pending");
      return;
    }

    root.currentRequest = request;
    root.pendingResult = null;
    root.pendingCancelled = true;
    root.completionPending = false;
    openLayer();
  }

  onStateChanged: state => {
    if (state === "closed") {
      const request = root.currentRequest;
      const result = root.pendingResult;
      const cancelled = root.pendingCancelled;
      root.currentRequest = null;
      root.pendingResult = null;
      root.pendingCancelled = true;
      root.completionPending = false;

      if (request !== null) {
        if (cancelled) {
          RegionSelectorController.cancel(request);
        } else {
          RegionSelectorController.resolve(request, result);
          result.destroy();
        }
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
    target: RegionSelectorController

    function onRequestStarted(request: var) {
      root.process(request);
    }
  }

  Component {
    id: resultComponent

    RectangularRegion {}
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
            if (!root.currentRequest) {
              console.warn("Selection completed, but no current request");
              return;
            }

            if (root.completionPending) {
              return;
            }

            root.completionPending = true;
            root.pendingResult = resultComponent.createObject(root, {
              source: region.source,
              screen: region.screen,
              x: region.x,
              y: region.y,
              width: region.width,
              height: region.height
            });

            root.pendingCancelled = false;
            root.closeLayer();
          }

          onCancelled: {
            if (!root.currentRequest) {
              console.warn("Selection cancelled, but no current request");
              return;
            }

            if (root.completionPending) {
              return;
            }

            root.completionPending = true;
            root.pendingResult = null;
            root.pendingCancelled = true;
            root.closeLayer();
          }
        }
      }
    }
  }
}
