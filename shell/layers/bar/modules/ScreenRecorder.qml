pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import qs.config
import qs.components
import qs.components.controls
import qs.layers.bar

BarModuleWrapper {
  id: root

  ShinyInteractiveLayer {
    id: layer
    anchors.fill: parent
    layerRadius: Config.appearance.rounding.xs

    onPressed: console.info("pressed")
  }

  ShinyTooltip {
    popupType: Popup.Window
    visible: layer.containsMouse
    text: "test"
  }

  contentItem: Item {
    implicitHeight: parent.implicitWidth

    ShinyIcon {
      anchors.centerIn: parent
      icon: "screen_record"
      font.pointSize: Config.appearance.font.size.md
      color: Config.appearance.color.overSurface
    }
  }
}
