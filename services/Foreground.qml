pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.utils

Singleton {
  id: root

  readonly property bool isAvailable: path !== ""
  property string path: ""

  function reload() {
    // First set running to false if alreay running
    if (foregroundScript.running)
      foregroundScript.running = false;

    foregroundScript.running = true;
  }

  Process {
    id: foregroundScript

    command: Utils.scriptCommand("extract-foreground.nu", Config.wallpaper.path, Paths.toPlain(Paths.cacheUrl))

    stdout: StdioCollector {
      onStreamFinished: {
        const result = this.text.trim();
        if (result !== "") {
          console.info(`Received foreground ${result} from extractor script`);
          root.path = result;
        }
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        const fullError = this.text.trim();
        if (fullError !== "") {
          const error = Utils.extractNuError(fullError);
          console.error(`Failed to extract foreground: ${error}`);
        }
      }
    }
  }

  Connections {
    target: Config.wallpaper

    function onEnabledChanged() {
      if (Config.wallpaper.enabled && Config.wallpaper.foreground) {
        root.reload();
      } else {
        foregroundScript.running = false;
        root.path = "";
      }
    }

    function onPathChanged() {
      if (Config.wallpaper.enabled && Config.wallpaper.foreground)
        root.reload();
    }

    function onForegroundChanged() {
      if (Config.wallpaper.enabled && Config.wallpaper.foreground) {
        root.reload();
      } else {
        root.path = "";
      }
    }

    function onCustomForegroundPathChanged() {
      const path = Config.wallpaper.customForegroundPath;
      if (Config.wallpaper.customForegroundPath) {
        foregroundScript.running = false;
        console.info(`Custom foreground path is set to ${path}`);
        root.path = path;
      } else {
        root.path = "";

        if (Config.wallpaper.enabled && Config.wallpaper.foreground)
          root.reload();
      }
    }
  }

  Component.onCompleted: {
    if (Config.wallpaper.enabled && Config.wallpaper.foreground)
      root.reload();
  }
}
