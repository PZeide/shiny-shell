pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell

Singleton {
  id: root

  readonly property real sfxVolume: 0.15

  function play(path: url) {
    Quickshell.execDetached(["pw-play", "--media-role", "Notification", "--volume", sfxVolume, path]);
  }
}
