pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils
import qs.layers.share_picker

Singleton {
  id: root

  property bool isAvailable: false
  readonly property alias isRecording: gsrProcess.running

  function startRecording() {
    if (!root.isAvailable || root.isRecording) {
      return;
    }
  }

  function stopRecording() {
    if (!root.isAvailable || !root.isRecording) {
      return;
    }

    gsrProcess.running = false;
  }

  Process {
    id: availabilityCheckProcess
    command: ["which", "gpu-screen-recorder"]
    onExited: exitCode => {
      if (exitCode === 0) {
        console.info("gpu-screen-recorder is available");
        root.isAvailable = true;
      }
    }
  }

  Process {
    id: gsrProcess
    command: ["gpu-screen-recorder", "-w", "portal", "-c", "mp4"]
  }

  IpcHandler {
    id: ipc
    target: "screen-recorder"

    function start(): string {
      if (!root.isAvailable) {
        return Helpers.fail("gpu-screen-recorder is not available");
      }

      if (root.isRecording) {
        return Helpers.fail("already recording");
      }

      root.startRecording();
      return Helpers.success("ok");
    }

    function stop(): string {
      if (!root.isAvailable) {
        return Helpers.fail("gpu-screen-recorder is not available");
      }

      if (!root.isRecording) {
        return Helpers.fail("not recording");
      }

      root.stopRecording();
      return Helpers.success("ok");
    }
  }

  Component.onCompleted: availabilityCheckProcess.exec({})
}
