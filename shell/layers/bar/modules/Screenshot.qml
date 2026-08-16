pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.services
import qs.config
import qs.components
import qs.components.controls
import qs.layers.bar

BarModuleWrapper {
  id: root

  ShinyInteractiveLayer {
    id: layer
    anchors.fill: parent
    enabled: Screenshot.isAvailable && !Screenshot.isCapturing
    layerRadius: Config.appearance.rounding.xs

    onPressed: Screenshot.capture()
  }

  ShinyTooltip {
    popupType: Popup.Window
    visible: layer.containsMouse
    placement: ShinyTooltip.Placement.Right
    text: {
      if (!Screenshot.isAvailable) {
        return "Screenshots are disabled";
      } else if (Screenshot.isCapturing) {
        return "Screenshot editor is open";
      } else if (Screenshot.lastError !== "") {
        return Screenshot.lastError;
      } else {
        return "Take screenshot";
      }
    }
  }

  contentItem: Item {
    implicitHeight: parent.implicitWidth

    ShinyIcon {
      anchors.centerIn: parent
      icon: "screenshot_region"
      font.pointSize: Config.appearance.font.size.md
      color: Screenshot.isCapturing ? Config.appearance.color.primary : Config.appearance.color.overSurface
    }
  }
}
