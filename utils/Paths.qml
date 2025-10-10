pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Qt.labs.platform

Singleton {
  readonly property string appSufix: "/shiny-shell"
  readonly property url homeUrl: StandardPaths.writableLocation(StandardPaths.HomeLocation)
  readonly property url cacheUrl: StandardPaths.writableLocation(StandardPaths.GenericCacheLocation) + appSufix
  readonly property url configUrl: StandardPaths.writableLocation(StandardPaths.GenericConfigLocation) + appSufix

  function assetPath(path: string): string {
    return Quickshell.shellPath(`assets/${path}`);
  }

  function assetUrl(path: string): url {
    return Qt.resolvedUrl(assetPath(path));
  }

  function toPlain(url: url): string {
    return url.toString().replace("file://", "");
  }
}
