pragma Singleton

import QtQuick
import Quickshell
import Qt.labs.platform

Singleton {
  id: root

  readonly property string appSufix: "/shiny-shell"
  readonly property url homeUrl: StandardPaths.writableLocation(StandardPaths.HomeLocation)
  readonly property url cacheUrl: StandardPaths.writableLocation(StandardPaths.GenericCacheLocation) + appSufix
  readonly property url configUrl: StandardPaths.writableLocation(StandardPaths.GenericConfigLocation) + appSufix

  function scriptUrl(path) {
    return Qt.resolvedUrl(`../Scripts/${path}`);
  }

  function fromUrl(url) {
    return url.toString().replace("file://", "");
  }
}
