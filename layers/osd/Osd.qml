pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

Scope {
  Connections {
    target: Brightness

    function onLinearValueChanged() {
    }
  }

  Connections {
    target: Audio

    function onMutedChanged(): void {
    }

    function onVolumeChanged(): void {
    }

    function onSourceMutedChanged(): void {
    }

    function onSourceVolumeChanged(): void {
    }
  }
}
