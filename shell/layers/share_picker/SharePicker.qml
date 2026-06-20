pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services
import qs.layers.share_picker

Item {
  id: root

  property list<var> requests: []

  function completeRequest(request: var, result: var, cancelled: bool): void {
    if (!root.requests.some(activeRequest => activeRequest.key === request.key)) {
      return;
    }

    root.requests = root.requests.filter(activeRequest => activeRequest.key !== request.key);

    if (cancelled) {
      SharePickerController.cancel(request);
    } else {
      SharePickerController.resolve(request, result);
    }
  }

  Connections {
    target: SharePickerController

    function onRequestStarted(request: var) {
      console.info(JSON.stringify(request));
      root.requests = [...root.requests, request];
    }
  }

  Repeater {
    model: ScriptModel {
      values: root.requests
    }

    delegate: SharePickerDialog {
      id: dialog

      required property var modelData
      readonly property var options: modelData.options

      availableMonitors: ScriptModel {
        values: HyprCompositor.monitors.values.filter(monitor => {
          if (!monitor || !monitor.lastIpcObject) {
            return false;
          }

          return dialog.options.allowMonitor === undefined || dialog.options.allowMonitor;
        })
      }

      availableWindows: ScriptModel {
        values: HyprCompositor.toplevels.values.filter(window => {
          if (!window || !window.lastIpcObject || !window.lastIpcObject.stableId || !window.lastIpcObject.class || window.lastIpcObject.class === "com.shiny-shell") {
            return false;
          }

          return dialog.options.allowWindow === undefined || dialog.options.allowWindow;
        })
      }

      allowCustomRegion: options.allowCustomRegion === undefined || options.allowCustomRegion
      allowRestoreToken: options.allowRestoreTokenDefault ?? false
      dialogParentWindowHandle: options.dialog_parent_window_handle ?? ""

      onSelectedMonitor: monitor => root.completeRequest(modelData, {
          type: "monitor",
          allowRestoreToken,
          monitor
        }, false)

      onSelectedWindow: (stableId, clazz, title) => root.completeRequest(modelData, {
          type: "window",
          allowRestoreToken,
          stableId,
          clazz,
          title
        }, false)

      onSelectedCustomRegion: region => root.completeRequest(modelData, {
          type: "custom",
          allowRestoreToken,
          region: {
            monitor: region.screen.name,
            x: region.x,
            y: region.y,
            width: region.width,
            height: region.height
          }
        }, false)

      onCancelled: root.completeRequest(modelData, null, true)
    }
  }
}
