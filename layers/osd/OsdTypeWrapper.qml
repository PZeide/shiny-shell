pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.effects
import qs.components.controls
import qs.config

Item {
  id: root

  signal sliderValueChanged(value: real)

  required property string icon
  required property real value
  property string tooltipFormat: `${Math.round(value * 100)}%`
  property bool inhibitClose: false

  implicitWidth: rectangle.implicitWidth + elevation.size * 2
  implicitHeight: rectangle.implicitHeight + elevation.size * 2

  ShinyElevatedLayer {
    id: elevation
    target: rectangle
  }

  ShinyRectangle {
    id: rectangle
    anchors.centerIn: parent
    color: Config.appearance.color.surfaceContainer
    implicitWidth: layout.implicitWidth + Config.appearance.padding.md * 2
    implicitHeight: layout.implicitHeight + Config.appearance.padding.sm * 2
    radius: Config.appearance.rounding.sm

    RowLayout {
      id: layout
      spacing: Config.appearance.spacing.md
      anchors.centerIn: parent

      ShinyIcon {
        Layout.alignment: Qt.AlignVCenter
        icon: root.icon
        font.pointSize: Config.appearance.font.size.xl
        fill: 1
      }

      ShinySlider {
        implicitTrackWidth: 150
        implicitTrackHeight: 10
        value: root.value

        onPressedChanged: root.inhibitClose = pressed
        onMoved: root.sliderValueChanged(value)
      }
    }
  }
}
