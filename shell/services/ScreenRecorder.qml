pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils
import qs.config
import qs.services

Singleton {
  id: root

  readonly property bool isAvailable: Config.screenRecorder.enabled
  readonly property alias isRecording: gsrProcess.running
  property string outputFile: ""
  property bool openOutputFile: false

  function startRecording() {
    if (!root.isAvailable || root.isRecording) {
      return;
    }

    const command = ["gpu-screen-recorder", "-w", "portal"];
    command.push("-c", Config.screenRecorder.container);
    command.push("-k", Config.screenRecorder.videoCodec);
    command.push("-ac", Config.screenRecorder.audioCodec);

    if (Config.screenRecorder.fps > 0) {
      command.push("-f", String(Config.screenRecorder.fps));
    }

    const audioOptions = [];

    if (Config.screenRecorder.audioOutput) {
      audioOptions.push("default_output");
    }

    if (Config.screenRecorder.audioInput) {
      audioOptions.push("default_input");
    }

    if (audioOptions.length > 0) {
      command.push("-a", audioOptions.join("|"));
    }

    const formattedFilename = Qt.formatDateTime(Clock.date, Config.screenRecorder.videoFilename);
    const outputFile = `${Config.screenRecorder.videoDirectory}/${formattedFilename}.${Config.screenRecorder.container}`;
    root.outputFile = outputFile;
    command.push("-o", outputFile);

    gsrProcess.exec({
      command
    });
  }

  function stopRecording(openOutputFile: bool) {
    if (!root.isAvailable || !root.isRecording) {
      return;
    }

    root.openOutputFile = openOutputFile;
    gsrProcess.running = false;
  }

  Process {
    id: gsrProcess

    onExited: {
      if (root.openOutputFile && root.outputFile !== "") {
        if (!Qt.openUrlExternally(`file://${root.outputFile}`)) {
          console.warn(`Failed to open output file: ${root.outputFile}`);
        }

        root.outputFile = "";
        root.openOutputFile = false;
      }
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
