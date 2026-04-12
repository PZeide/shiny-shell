pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils
import qs.config

Singleton {
  id: root

  readonly property bool isAvailable: Config.screenRecorder.enabled
  readonly property alias isRecording: gsrProcess.running

  function startRecording() {
    if (!root.isAvailable || root.isRecording) {
      return;
    }

    gsrProcess.exec({});
  }

  function stopRecording() {
    if (!root.isAvailable || !root.isRecording) {
      return;
    }

    gsrProcess.running = false;
  }

  Process {
    id: gsrProcess

    command: {
      const base = ["gpu-screen-recorder", "-w", "portal"];
      base.push("-c", Config.screenRecorder.container);
      base.push("-k", Config.screenRecorder.videoCodec);
      base.push("-ac", Config.screenRecorder.audioCodec);
      base.push("-f", String(Config.screenRecorder.fps));

      const audio = [];

      if (Config.screenRecorder.audioOutput) {
        audio.push("default_output");
      }

      if (Config.screenRecorder.audioInput) {
        audio.push("default_input");
      }

      if (audio.length > 0) {
        base.push("-a", audio.join("|"));
      }

      base.push("-o", `${Config.screenRecorder.videoDirectory}/${Config.screenRecorder.videoFilename}`);
      return base;
    }
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
}
