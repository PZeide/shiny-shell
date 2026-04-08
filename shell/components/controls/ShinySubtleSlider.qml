pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import qs.config
import qs.components
import qs.components.controls.styles
import qs.utils.animations

ShinyCooperativeSlider {
  id: root

  enum Variant {
    Primary,
    Secondary
  }

  property int variant: ShinySubtleSlider.Variant.Primary
  readonly property var configuration: ShinySliderStyles.configurations[variant]
  property real implicitDefaultTrackHeight: 6
  property real implicitHoveredTrackHeight: 10
  property real implicitPressedTrackHeight: 12
  property real implicitDefaultHandleWidth: 3
  property real implicitPressedHandleWidth: 5
  property real implicitDefaultHandleHeight: implicitHoveredTrackHeight + 6
  property real implicitPressedHandleHeight: implicitPressedTrackHeight + 8
  property real trackRadius: implicitDefaultTrackHeight / 2
  property bool showTooltip: false
  property int tooltipPlacement: ShinyTooltip.Placement.Top
  property string tooltipText: `${Math.round(value * 100)}%`

  hoverEnabled: root.enabled
  orientation: Qt.Horizontal
  from: 0
  to: 1
  implicitWidth: 200 + leftPadding + rightPadding
  implicitHeight: Math.max(implicitDefaultTrackHeight, implicitHoveredTrackHeight, implicitPressedTrackHeight) + topPadding + bottomPadding
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
    color: root.enabled ? root.configuration.track.default : root.configuration.track.disabled
    radius: root.trackRadius
    y: root.height / 2 - height / 2

    height: {
      const padding = root.topPadding + root.bottomPadding;

      if (root.pressed) {
        return root.implicitPressedTrackHeight + padding;
      } else if (root.hovered) {
        return root.implicitHoveredTrackHeight + padding;
      } else {
        return root.implicitDefaultTrackHeight + padding;
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
      color: root.enabled ? root.configuration.highlight.default : root.configuration.highlight.disabled
      topLeftRadius: root.trackRadius
      bottomLeftRadius: root.trackRadius
      topRightRadius: root.trackRadius / 2
      bottomRightRadius: root.trackRadius / 2
    }
  }

  handle: ShinyRectangle {
    id: handle
    x: root.visualPosition * (root.width - width)
    y: root.height / 2 - height / 2
    radius: Config.appearance.rounding.full
    color: root.enabled ? root.configuration.handle.default : root.configuration.handle.disabled
    opacity: root.hovered || root.pressed ? 1 : 0

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

    Behavior on opacity {
      EffectNumberAnimation {}
    }

    Behavior on x {
      enabled: !root.hovered && !root.pressed
      EffectNumberAnimation {}
    }

    ShinyTooltip {
      visible: root.showTooltip && (root.hovered || root.pressed)
      placement: root.tooltipPlacement
      text: root.tooltipText
      delay: 0
    }
  }
}
