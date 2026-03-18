pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
  id: root

  readonly property bool isActive: false

  IpcHandler {
    id: ipc
    target: "screen-recorder"

    function start(): string {
      return Helpers.success("ok");
    }

    function stop(): string {
      return Helpers.success("ok");
    }
  }
}
