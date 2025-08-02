pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Utils

Singleton {
  id: root

  property bool canShow: false
  property string path

  function init() {
    if (Config.wallpaper.enabled && Config.wallpaper.foreground) {
      console.info("Starting initial foreground setup");
      foregroundExtractor.running = true;
    }
  }

  Process {
    id: foregroundExtractor

    command: ["bash", Paths.fromUrl(Paths.scriptUrl("extract-foreground.sh")), Paths.fromUrl(Config.wallpaper.path), Paths.fromUrl(Paths.cacheUrl)]

    stdout: StdioCollector {
      onStreamFinished: {
        const result = this.text.trim();
        if (result) {
          console.info(`Received foreground ${result} from extractor script`);
          root.canShow = true;
          root.path = result;
        }
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        const error = this.text.trim();
        if (error) {
          console.error(`Failed to extract foreground: ${error}`);
        }
      }
    }
  }

  Connections {
    target: Config.wallpaper

    function onEnabledChanged() {
      if (Config.wallpaper.enabled && Config.wallpaper.foreground) {
        foregroundExtractor.running = true;
      } else {
        root.canShow = false;
        root.path = undefined;
      }
    }

    function onPathChanged() {
      if (Config.wallpaper.enabled && Config.wallpaper.foreground) {
        foregroundExtractor.running = true;
      }
    }

    function onForegroundChanged() {
      if (Config.wallpaper.enabled && Config.wallpaper.foreground) {
        foregroundExtractor.running = true;
      } else {
        root.canShow = false;
        root.path = undefined;
      }
    }

    function onCustomForegroundPathChanged() {
      const path = Config.wallpaper.customForegroundPath;
      if (Config.wallpaper.customForegroundPath) {
        console.info(`Custom foreground path is set to ${path}`);
        root.path = path;
        root.canShow = true;
      } else {
        root.canShow = false;
        root.path = undefined;

        if (Config.wallpaper.enabled && Config.wallpaper.foreground) {
          foregroundExtractor.running = true;
        }
      }
    }
  }
}
