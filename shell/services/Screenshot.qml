pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Shiny.Screenshot as ScreenshotPlugin
import qs.config
import qs.utils

Singleton {
  id: root

  readonly property bool isAvailable: Config.screenshot.enabled
  readonly property bool isCapturing: (currentRequest !== null && !currentRequest.finished) || sattyProcess.running
  property var currentRequest: null
  property string lastError: ""

  function capture() {
    if (!root.isAvailable || root.isCapturing) {
      return;
    }

    root.lastError = "";
    root.currentRequest = ScreenshotPlugin.ScreenshotManager.screenshot(true);
    if (root.currentRequest.finished) {
      root.finishRequest();
    }
  }

  function finishRequest() {
    const request = root.currentRequest;
    if (request === null) {
      return;
    }

    if (request.response === 0 && !request.failed) {
      if (request.path === "") {
        root.lastError = "Screenshot portal returned a non-local file";
        console.warn(root.lastError);
      } else {
        sattyProcess.exec({
          command: root.sattyCommand(request.path)
        });
      }
    } else if (request.response !== 1) {
      root.lastError = request.errorMessage === "" ? `Screenshot failed with response ${request.response}` : request.errorMessage;
      console.warn(`Screenshot failed: ${root.lastError}`);
    }

    root.currentRequest = null;
  }

  function sattyCommand(path: string): list<string> {
    const command = ["satty", "--resize", "smart", "--floating-hack", "--no-window-decoration", "--disable-notifications", "--filename", path];

    if (Config.screenshot.annotator.outputFilename !== "") {
      command.push("--output-filename", Config.screenshot.annotator.outputFilename);
    }

    if (Config.screenshot.annotator.initialTool !== "") {
      command.push("--initial-tool", Config.screenshot.annotator.initialTool);
    }

    if (Config.screenshot.annotator.earlyExit.length > 0) {
      command.push("--early-exit", ...Config.screenshot.annotator.earlyExit);
    }

    if (Config.screenshot.annotator.annotationSizeFactor > 0) {
      command.push("--annotation-size-factor", String(Config.screenshot.annotator.annotationSizeFactor));
    }

    if (Config.screenshot.annotator.actionsOnEnter.length > 0) {
      command.push("--actions-on-enter", ...Config.screenshot.annotator.actionsOnEnter);
    }

    if (Config.screenshot.annotator.actionsOnEscape.length > 0) {
      command.push("--actions-on-escape", ...Config.screenshot.annotator.actionsOnEscape);
    }

    if (Config.screenshot.annotator.actionsOnRightClick.length > 0) {
      command.push("--actions-on-right-click", ...Config.screenshot.annotator.actionsOnRightClick);
    }

    return command;
  }

  Connections {
    target: root.currentRequest
    enabled: root.currentRequest !== null

    function onCompleted() {
      root.finishRequest();
    }

    function onCancelled() {
      root.finishRequest();
    }

    function onFailedWithError() {
      root.finishRequest();
    }
  }

  Process {
    id: sattyProcess

    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) {
        root.lastError = `Satty exited with code ${exitCode}`;
        console.warn(`${root.lastError} (status ${exitStatus})`);
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "screenshot"

    function capture(): string {
      if (!root.isAvailable) {
        return Helpers.fail("screenshot capture is not available");
      }

      if (root.isCapturing) {
        return Helpers.fail("screenshot capture is already active");
      }

      root.capture();
      return Helpers.success("ok");
    }
  }
}
