pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.config

Scope {
  id: root

  readonly property ShellScreen focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
  property int currentType: -1
  property int nextType: -1
  property bool inhibitClose: false

  enum Type {
    AudioSink,
    AudioSource,
    Brightness
  }

  function show(type: int) {
    if (root.inhibitClose)
      return;

    if (currentType === -1) {
      // No osd currently shown
      currentType = type;
      timer.start();
      layer.openLayer();
      return;
    }

    if (currentType === type) {
      // Same type already shown, extends timeout
      timer.restart();
      return;
    }

    // Different type, we close the current osd and queue the next
    timer.stop();
    layer.closeLayer();
    root.nextType = type;
  }

  Timer {
    id: timer
    interval: Config.osd.timeout

    onTriggered: {
      timer.stop();
      layer.closeLayer();
      root.inhibitClose = false;
    }
  }

  OsdLayer {
    id: layer
    screen: root.focusedScreen
    type: root.currentType

    onInhibitCloseChanged: root.inhibitClose = inhibitClose
  }

  Connections {
    target: Brightness

    function onUserValueChanged() {
      if (Config.osd.brightnessEnabled)
        root.show(Osd.Type.Brightness);
    }
  }

  Connections {
    target: Audio

    function onSinkMutedChanged() {
      if (Config.osd.audioSinkEnabled)
        root.show(Osd.Type.AudioSink);
    }

    function onSinkVolumeChanged() {
      if (Config.osd.audioSinkEnabled)
        root.show(Osd.Type.AudioSink);
    }

    function onSourceMutedChanged() {
      if (Config.osd.audioSourceEnabled)
        root.show(Osd.Type.AudioSource);
    }

    function onSourceVolumeChanged() {
      if (Config.osd.audioSourceEnabled)
        root.show(Osd.Type.AudioSource);
    }
  }

  Connections {
    target: layer

    function onStateChanged() {
      if (layer.state !== "closed")
        return;

      if (root.nextType !== -1) {
        root.currentType = root.nextType;
        root.nextType = -1;

        Qt.callLater(() => {
          timer.start();
          layer.openLayer();
        });
      } else {
        root.currentType = -1;
      }
    }
  }

  onInhibitCloseChanged: {
    if (inhibitClose) {
      timer.stop();
    } else {
      timer.start();
    }
  }
}
