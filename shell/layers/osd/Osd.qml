pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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
  property var activeTypes: []
  property var inhibitedTypes: []
  property var removingTypes: []
  property int expiringType: -1
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
    if (root.state === "closed") {
      root.activeTypes = [];
      root.inhibitedTypes = [];
      root.removingTypes = [];
      root.expiringType = -1;
      activeTypesModel.clear();
    }
  }

  function show(type: int) {
    if (root.inhibitedTypes.includes(type))
      return;

    const removingIndex = root.removingTypes.indexOf(type);
    if (removingIndex !== -1) {
      const types = root.removingTypes.slice();
      types.splice(removingIndex, 1);
      root.removingTypes = types;
    }

    if (root.expiringType !== -1) {
      if (root.expiringType !== type) {
        root.activeTypes = [];
        root.removingTypes = [];
        activeTypesModel.clear();
      }
      root.expiringType = -1;
    }

    const alreadyShown = root.activeTypes.includes(type);

    if (!alreadyShown) {
      root.activeTypes = root.activeTypes.concat(type);
      activeTypesModel.append({ osdType: type });
    }

    root.restartTimer(type);

    if (!root.opened) {
      root.updatePanelWindow();
      root.openLayer();
    }
  }

  function hide(type: int) {
    const index = root.activeTypes.indexOf(type);
    if (index === -1 || root.removingTypes.includes(type))
      return;

    const visibleTypes = root.activeTypes.filter(activeType => !root.removingTypes.includes(activeType));
    if (visibleTypes.length === 1) {
      // Keep the final panel around for the exit animation.
      root.expiringType = type;
      root.closeLayer();
      return;
    }

    root.removingTypes = root.removingTypes.concat(type);
  }

  function finishHide(type: int) {
    const removingIndex = root.removingTypes.indexOf(type);
    if (removingIndex === -1)
      return;

    const types = root.activeTypes.slice();
    const index = types.indexOf(type);
    if (index === -1)
      return;

    types.splice(index, 1);
    root.activeTypes = types;
    activeTypesModel.remove(index);

    const removingTypes = root.removingTypes.slice();
    removingTypes.splice(removingIndex, 1);
    root.removingTypes = removingTypes;
  }

  function restartTimer(type: int) {
    switch (type) {
    case Osd.Type.AudioSink:
      audioSinkTimer.restart();
      break;
    case Osd.Type.AudioSource:
      audioSourceTimer.restart();
      break;
    case Osd.Type.Brightness:
      brightnessTimer.restart();
      break;
    }
  }

  function stopTimer(type: int) {
    switch (type) {
    case Osd.Type.AudioSink:
      audioSinkTimer.stop();
      break;
    case Osd.Type.AudioSource:
      audioSourceTimer.stop();
      break;
    case Osd.Type.Brightness:
      brightnessTimer.stop();
      break;
    }
  }

  function setInteractionActive(type: int, active: bool) {
    const index = root.inhibitedTypes.indexOf(type);

    if (active) {
      if (index === -1) {
        root.inhibitedTypes = root.inhibitedTypes.concat(type);
      }
      root.stopTimer(type);
    } else {
      if (index !== -1) {
        const types = root.inhibitedTypes.slice();
        types.splice(index, 1);
        root.inhibitedTypes = types;
      }
      root.restartTimer(type);
    }
  }

  function updatePanelWindow() {
    root.panelWindow = Helpers.focusedShellScreen();
  }

  Timer {
    id: audioSinkTimer
    interval: Config.osd.timeout
    onTriggered: root.hide(Osd.Type.AudioSink)
  }

  Timer {
    id: audioSourceTimer
    interval: Config.osd.timeout
    onTriggered: root.hide(Osd.Type.AudioSource)
  }

  Timer {
    id: brightnessTimer
    interval: Config.osd.timeout
    onTriggered: root.hide(Osd.Type.Brightness)
  }

  ListModel {
    id: activeTypesModel
  }

  Loader {
    id: panelLoader
    active: root.shown && root.activeTypes.length > 0

    sourceComponent: ShinyWindow {
      name: "osd"
      screen: root.panelWindow
      anchors.bottom: true
      implicitWidth: panelColumn.implicitWidth
      implicitHeight: screen.height
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay

      mask: Region {
        item: panelColumn
      }

      ColumnLayout {
        id: panelColumn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -height + root.appearanceFactor * (Config.appearance.spacing.sm + height)
        spacing: Config.appearance.spacing.xs
        opacity: root.panelOpacity
        scale: root.panelScale

        Repeater {
          model: activeTypesModel

          delegate: Item {
            id: stackItem

            required property int osdType
            property real appearanceFactor: root.state === "opened" ? 0 : 1

            Layout.alignment: Qt.AlignHCenter
            implicitWidth: panel.implicitWidth
            implicitHeight: panel.implicitHeight * appearanceFactor
            opacity: appearanceFactor
            scale: 0.85 + appearanceFactor * 0.15
            transformOrigin: Item.Bottom

            Component.onCompleted: appearanceFactor = 1

            onAppearanceFactorChanged: {
              if (appearanceFactor === 0 && root.removingTypes.includes(osdType)) {
                root.finishHide(osdType);
              }
            }

            Connections {
              target: root

              function onRemovingTypesChanged() {
                stackItem.appearanceFactor = root.removingTypes.includes(stackItem.osdType) ? 0 : 1;
              }
            }

            Behavior on appearanceFactor {
              EffectNumberAnimation {}
            }

            OsdPanel {
              id: panel

              anchors.horizontalCenter: parent.horizontalCenter
              anchors.bottom: parent.bottom
              type: stackItem.osdType

              onInteractionActiveChanged: {
                root.setInteractionActive(stackItem.osdType, interactionActive);
              }
            }
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
    active: Config.osd.audioSinkEnabled && (Audio.defaultSink?.ready ?? false) && Audio.defaultSink?.audio != null

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
    active: Config.osd.audioSourceEnabled && (Audio.defaultSource?.ready ?? false) && Audio.defaultSource?.audio != null

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

    sourceComponent: QtObject {
      id: brightnessWatcher

      property var observedDevice: Brightness.defaultDevice
      property real lastBrightness: NaN
      readonly property Connections connection: Connections {
        target: brightnessWatcher.observedDevice

        function onBrightnessChanged() {
          const brightness = brightnessWatcher.observedDevice?.brightness ?? NaN;
          if (brightness === brightnessWatcher.lastBrightness)
            return;

          brightnessWatcher.lastBrightness = brightness;
          root.show(Osd.Type.Brightness);
        }
      }

      Component.onCompleted: lastBrightness = observedDevice?.brightness ?? NaN
      onObservedDeviceChanged: lastBrightness = observedDevice?.brightness ?? NaN
    }
  }
}
