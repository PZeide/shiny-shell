pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.services
import qs.config
import qs.components
import qs.components.controls
import qs.layers.bar
import qs.utils

BarModuleWrapper {
  id: root

  ShinyInteractiveLayer {
    id: layer
    anchors.fill: parent
    layerRadius: Config.appearance.rounding.xs

    onPressed: event => {
      if (ScreenRecorder.isRecording) {
        ScreenRecorder.stopRecording(event.modifiers & Qt.ShiftModifier);
      } else if (ScreenRecorder.isIdling) {
        ScreenRecorder.startRecording();
      }
    }
  }

  ShinyTooltip {
    popupType: Popup.Window
    visible: layer.containsMouse
    placement: ShinyTooltip.Placement.Right
    text: {
      if (ScreenRecorder.isSelectingSource) {
        return "Selecting source…";
      } else if (ScreenRecorder.isRecording) {
        return `Stop recording · ${Formatting.numericDuration(ScreenRecorder.recordingSeconds)}`;
      } else {
        return "Start recording";
      }
    }
  }

  contentItem: Item {
    implicitHeight: parent.implicitWidth

    ShinyIcon {
      anchors.centerIn: parent
      icon: ScreenRecorder.isSelectingSource ? "select_window" : (ScreenRecorder.isRecording ? "stop_circle" : "screen_record")
      font.pointSize: Config.appearance.font.size.md
      color: ScreenRecorder.isSelectingSource ? Config.appearance.color.tertiary : (ScreenRecorder.isRecording ? Config.appearance.color.primary : Config.appearance.color.overSurface)
    }
  }
}
