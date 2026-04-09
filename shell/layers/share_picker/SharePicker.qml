pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.utils

Item {
  id: root

  property list<var> requests: []

  function processRequest(request: var) {
    requests.push(request);
  }

  function handleResult(key: string, result: var) {
    for (let i = 0; i < requests.length; i++) {
      if (requests[i].key === key) {
        requests.splice(i, 1);

        if (result !== null) {
          ipc.result(JSON.stringify({
            key,
            status: "selected",
            result
          }));
        } else {
          ipc.result(JSON.stringify({
            key,
            status: "cancelled"
          }));
        }

        return;
      }
    }
  }

  Repeater {
    model: ScriptModel {
      values: root.requests.filter(request => request)
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

          if (dialog.options.availableMonitors === undefined || dialog.options.availableMonitors === "*") {
            return true;
          }

          return dialog.options.availableMonitors.includes(monitor.description);
        })
      }

      availableWindows: ScriptModel {
        values: HyprCompositor.toplevels.values.filter(window => {
          if (!window || !window.lastIpcObject || !window.lastIpcObject.class || window.lastIpcObject.class === "com.shiny-shell") {
            return false;
          }

          if (dialog.options.availableWindows === undefined || dialog.options.availableWindows === "*") {
            return true;
          }

          return dialog.options.availableWindows.includes(window.address);
        })
      }

      allowCustomRegion: options.allowCustomRegion === undefined || options.allowCustomRegion
      allowRestoreToken: options.allowRestoreTokenDefault ?? false

      onSelectedMonitor: monitor => root.handleResult(modelData.key, {
          type: "monitor",
          allowRestoreToken,
          monitor
        })

      onSelectedWindow: window => root.handleResult(modelData.key, {
          type: "window",
          allowRestoreToken,
          window
        })

      onSelectedCustomRegion: region => root.handleResult(modelData.key, {
          type: "custom",
          allowRestoreToken,
          region: {
            monitor: region.screen.name,
            x: region.x,
            y: region.y,
            width: region.width,
            height: region.height
          }
        })

      onCancelled: root.handleResult(modelData.key, null)
    }
  }

  IpcHandler {
    id: ipc
    target: "share-picker"

    signal result(result: string)

    function request(options: string): string {
      const key = Math.random().toString(36).substring(2, 15);
      root.processRequest({
        key,
        options: JSON.parse(options)
      });

      return Helpers.success(key);
    }
  }
}
