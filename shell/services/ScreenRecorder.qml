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

  enum State {
    NotRecording,
    SelectingSource,
    Recording
  }

  readonly property bool isAvailable: Config.screenRecorder.enabled
  readonly property bool isActive: state !== ScreenRecorder.State.NotRecording
  readonly property bool isSelectingSource: state === ScreenRecorder.State.SelectingSource
  readonly property bool isRecording: state === ScreenRecorder.State.Recording
  readonly property bool isIdling: state === ScreenRecorder.State.NotRecording
  readonly property int recordingSeconds: isRecording ? Math.max(0, Math.floor((Clock.date.getTime() - recordingStartedAt) / 1000)) : 0
  property int state: ScreenRecorder.State.NotRecording
  property double recordingStartedAt: 0
  property string outputFile: ""
  property bool openOutputFile: false

  function startRecording() {
    if (!root.isAvailable || root.isActive) {
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

    root.state = ScreenRecorder.State.SelectingSource;
    root.recordingStartedAt = 0;
    gsrProcess.exec({
      command
    });
  }

  function stopRecording(openOutputFile = false) {
    if (!root.isAvailable || !root.isRecording) {
      return;
    }

    root.openOutputFile = openOutputFile;
    gsrProcess.running = false;
  }

  Process {
    id: gsrProcess

    stderr: SplitParser {
      onRead: line => {
        if (root.isSelectingSource && line.includes("pipewire negotiation finished")) {
          root.recordingStartedAt = Clock.date.getTime();
          root.state = ScreenRecorder.State.Recording;
        }
      }
    }

    onExited: {
      const completedOutputFile = root.outputFile;
      const shouldOpenOutputFile = root.openOutputFile;

      root.state = ScreenRecorder.State.NotRecording;
      root.recordingStartedAt = 0;
      root.outputFile = "";
      root.openOutputFile = false;

      if (shouldOpenOutputFile && completedOutputFile !== "") {
        if (!Qt.openUrlExternally(`file://${completedOutputFile}`)) {
          console.warn(`Failed to open output file: ${completedOutputFile}`);
        }
      }
    }

    onRunningChanged: {
      if (!running && root.isActive) {
        root.state = ScreenRecorder.State.NotRecording;
        root.recordingStartedAt = 0;
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

      if (root.isActive) {
        return Helpers.fail("screen recorder is already active");
      }

      root.startRecording();
      return Helpers.success("ok");
    }

    function stop(): string {
      if (!root.isAvailable) {
        return Helpers.fail("gpu-screen-recorder is not available");
      }

      if (!root.isRecording) {
        return Helpers.fail("screen recorder is not recording");
      }

      root.stopRecording();
      return Helpers.success("ok");
    }
  }
}
