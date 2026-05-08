pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Shiny.Brightness
import Qt.labs.synchronizer
import qs.config
import qs.components.containers
import qs.components.misc
import qs.utils
import qs.utils.animations
import qs.services

ShinyLayerAnimationHelper {
  id: root

  enum Type {
    AudioSink,
    AudioSource,
    Brightness
  }

  property ShellScreen panelWindow: null
  property int currentType: -1
  property int nextType: -1
  property bool inhibitClose: false
  property real panelOpacity: 0
  property real panelScale: 0.75
  property real appearanceFactor: 0

  enter: Transition {
    EffectNumberAnimation {
      target: root
      property: "panelOpacity"
      from: root.panelOpacity
      to: 1
    }

    EffectNumberAnimation {
      target: root
      property: "panelScale"
      from: root.panelScale
      to: 1
    }

    EffectNumberAnimation {
      target: root
      property: "appearanceFactor"
      from: root.appearanceFactor
      to: 1
    }
  }

  exit: Transition {
    EffectNumberAnimation {
      target: root
      property: "panelOpacity"
      from: root.panelOpacity
      to: 0
    }

    EffectNumberAnimation {
      target: root
      property: "panelScale"
      from: root.panelScale
      to: 0.75
    }

    EffectNumberAnimation {
      target: root
      property: "appearanceFactor"
      from: root.appearanceFactor
      to: 0
    }
  }

  onStateChanged: {
    if (root.state !== "closed")
      return;

    if (root.nextType !== -1) {
      root.currentType = root.nextType;
      root.nextType = -1;

      Qt.callLater(() => {
        timer.start();
        root.updatePanelWindow();
        root.openLayer();
      });
    } else {
      root.currentType = -1;
    }
  }

  function show(type: int) {
    if (root.inhibitClose)
      return;

    if (currentType === -1) {
      // No osd currently shown
      currentType = type;
      timer.start();
      root.updatePanelWindow();
      root.openLayer();
      return;
    }

    if (currentType === type) {
      // Same type already shown, extends timeout
      timer.restart();
      return;
    }

    // Different type, we close the current osd and queue the next
    timer.stop();
    root.closeLayer();
    root.nextType = type;
  }

  function updatePanelWindow() {
    root.panelWindow = Helpers.focusedShellScreen();
  }

  Timer {
    id: timer
    interval: Config.osd.timeout

    onTriggered: {
      timer.stop();
      root.closeLayer();
      root.inhibitClose = false;
    }
  }

  Loader {
    id: panelLoader
    active: root.shown && root.currentType != -1

    sourceComponent: ShinyWindow {
      name: "osd"
      screen: root.panelWindow
      anchors.bottom: true
      implicitWidth: panel.implicitWidth
      implicitHeight: panel.implicitHeight + Config.appearance.spacing.sm
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay

      mask: Region {
        item: panel
      }

      OsdPanel {
        id: panel
        type: root.currentType
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -height + root.appearanceFactor * (Config.appearance.spacing.sm + height)
        opacity: root.panelOpacity
        scale: root.panelScale

        onInteractionActiveChanged: {
          root.inhibitClose = interactionActive;

          if (interactionActive) {
            timer.stop();
          } else {
            timer.start();
          }
        }
      }
    }
  }

  Connections {
    target: Quickshell

    function onScreensChanged() {
      if (!Quickshell.screens.values.includes(root.panelWindow)) {
        root.updatePanelWindow();
      }
    }
  }

  Loader {
    active: Config.osd.audioSinkEnabled && Audio.defaultSink?.audio != null

    sourceComponent: Connections {
      target: Audio.defaultSink?.audio

      function onMutedChanged() {
        root.show(Osd.Type.AudioSink);
      }

      function onVolumeChanged() {
        root.show(Osd.Type.AudioSink);
      }
    }
  }

  Loader {
    active: Config.osd.audioSourceEnabled && Audio.defaultSource?.audio != null

    sourceComponent: Connections {
      target: Audio.defaultSource?.audio

      function onMutedChanged() {
        root.show(Osd.Type.AudioSource);
      }

      function onVolumeChanged() {
        root.show(Osd.Type.AudioSource);
      }
    }
  }

  Loader {
    active: Config.osd.brightnessEnabled && Brightness.isAvailable && Brightness.defaultDevice !== null

    sourceComponent: Connections {
      target: Brightness.defaultDevice

      function onBrightnessChanged() {
        root.show(Osd.Type.Brightness);
      }
    }
  }
}
