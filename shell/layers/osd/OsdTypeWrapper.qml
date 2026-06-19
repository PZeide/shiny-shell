pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.controls
import qs.components.containers
import qs.config

Item {
  id: root

  signal sliderValueChanged(value: real)

  required property string icon
  required property real value
  property alias sliderEnabled: slider.enabled
  property bool interactionActive: layer.containsMouse || slider.hovered || slider.pressed

  implicitWidth: rectangle.implicitWidth + elevation.horizontalPadding
  implicitHeight: rectangle.implicitHeight + elevation.verticalPadding

  ShinyElevatedContainer {
    id: elevation
    target: rectangle
  }

  ShinyRectangle {
    id: rectangle
    color: Config.appearance.color.surface
    implicitWidth: layout.implicitWidth + Config.appearance.padding.md * 2
    implicitHeight: layout.implicitHeight + Config.appearance.padding.sm * 2
    radius: Config.appearance.rounding.sm

    MouseArea {
      id: layer
      anchors.fill: parent
      hoverEnabled: true
    }

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

      ShinySubtleSlider {
        id: slider
        implicitWidth: 150
        cooperativeValue: root.value
        showTooltip: true

        onMoved: root.sliderValueChanged(value)
      }
    }
  }
}
