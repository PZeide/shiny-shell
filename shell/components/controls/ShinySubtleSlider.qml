pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import qs.config
import qs.components
import qs.utils.animations

ShinyCooperativeSlider {
  id: root

  property real implicitTrackWidth: 50
  property real implicitDefaultTrackHeight: 6
  property real implicitHoveredTrackHeight: 10
  property real implicitPressedTrackHeight: 12
  property real implicitDefaultHandleWidth: 3
  property real implicitPressedHandleWidth: 5
  property real implicitDefaultHandleHeight: implicitHoveredTrackHeight + 6
  property real implicitPressedHandleHeight: implicitPressedTrackHeight + 8
  property real trackRadius: implicitDefaultTrackHeight / 2
  property color trackColor: Config.appearance.color.secondaryContainer
  property color highlightColor: Config.appearance.color.primary
  property color handleColor: Config.appearance.color.primaryFixed
  property bool showTooltip: false
  property string tooltipText: `${Math.round(value * 100)}%`

  hoverEnabled: root.enabled
  orientation: Qt.Horizontal
  from: 0
  to: 1
  implicitWidth: implicitTrackWidth
  implicitHeight: Math.max(implicitDefaultTrackHeight, implicitHoveredTrackHeight, implicitPressedTrackHeight)
  stepSize: 0
  snapMode: T.Slider.NoSnap

  // Disable key presses it causes more troubles than it solves
  Keys.onPressed: event => event.accepted = focus

  Behavior on value {
    enabled: !root.pressed
    EffectNumberAnimation {}
  }

  MouseArea {
    id: layer
    hoverEnabled: root.enabled
    anchors.fill: parent
    cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
    onPressed: mouse => mouse.accepted = false
  }

  background: ShinyRectangle {
    anchors.verticalCenter: parent.verticalCenter
    color: root.trackColor
    radius: root.trackRadius
    y: root.height / 2 - height / 2
    width: root.width
    height: {
      if (root.pressed) {
        return root.implicitPressedTrackHeight;
      } else if (root.hovered) {
        return root.implicitHoveredTrackHeight;
      } else {
        return root.implicitDefaultTrackHeight;
      }
    }

    Behavior on height {
      EffectNumberAnimation {}
    }

    ShinyRectangle {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: root.visualPosition * parent.width
      color: root.highlightColor
      topLeftRadius: root.trackRadius
      bottomLeftRadius: root.trackRadius
      topRightRadius: Config.appearance.rounding.xxs
      bottomRightRadius: Config.appearance.rounding.xxs
    }
  }

  handle: ShinyRectangle {
    id: handle
    x: root.visualPosition * (root.width - width)
    y: root.height / 2 - height / 2
    radius: Config.appearance.rounding.full
    color: root.handleColor

    implicitWidth: {
      if (root.pressed) {
        return root.implicitPressedHandleWidth;
      } else {
        return root.implicitDefaultHandleWidth;
      }
    }

    implicitHeight: {
      if (root.pressed) {
        return root.implicitPressedHandleHeight;
      } else if (root.hovered) {
        return root.implicitDefaultHandleHeight;
      } else {
        return 0;
      }
    }

    // Animating implicitWidth cause issues when dragging
    // Not needed anyway because the difference is so tiny the animation is usually not noticeable

    Behavior on implicitHeight {
      EffectNumberAnimation {}
    }

    Behavior on x {
      enabled: !root.hovered && !root.pressed
      EffectNumberAnimation {}
    }

    ShinyTooltip {
      visible: root.showTooltip && (root.hovered || root.pressed)
      text: root.tooltipText
      delay: 0
    }
  }
}
