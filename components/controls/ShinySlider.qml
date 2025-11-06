pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates
import qs.config
import qs.components
import qs.utils.animations

Slider {
  id: root

  property real implicitDefaultHandleWidth: 3
  property real implicitPressedHandleWidth: 1.5
  property real implicitTrackWidth: 50
  property real implicitTrackHeight: 10
  property real implicitTrackDotSize: 4
  property real handleHorizontalMargins: Config.appearance.spacing.xxs
  property real trackRadius: implicitTrackHeight / 2
  property list<real> stopIndicatorValues: [1]
  property color highlightColor: Config.appearance.color.primary
  property color trackColor: Config.appearance.color.secondaryContainer
  property color handleColor: Config.appearance.color.primary
  property color dotColor: Config.appearance.color.overSecondaryContainer
  property color dotColorHighlighted: Config.appearance.color.overPrimary
  property string tooltipText: `${Math.round(value * 100)}%`
  readonly property real effectiveDraggingWidth: implicitTrackWidth - leftPadding - rightPadding

  from: 0
  to: 1
  leftPadding: handleHorizontalMargins
  rightPadding: handleHorizontalMargins
  implicitWidth: implicitTrackWidth
  implicitHeight: implicitTrackHeight

  Behavior on value {
    EffectNumberAnimation {}
  }

  Behavior on handleHorizontalMargins {
    EffectNumberAnimation {}
  }

  component TrackDot: ShinyRectangle {
    required property real value

    property real normalizedValue: (value - root.from) / (root.to - root.from)
    x: root.handleHorizontalMargins + (normalizedValue * root.effectiveDraggingWidth) - (root.implicitTrackDotSize / 2)
    implicitWidth: root.implicitTrackDotSize
    implicitHeight: root.implicitTrackDotSize
    radius: Config.appearance.rounding.full
    color: normalizedValue > root.visualPosition ? root.dotColor : root.dotColorHighlighted
  }

  MouseArea {
    anchors.fill: parent
    onPressed: mouse => mouse.accepted = false
    cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
  }

  background: Item {
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: root.implicitTrackWidth
    implicitHeight: root.implicitTrackHeight

    ShinyRectangle {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      implicitWidth: root.handleHorizontalMargins + (root.visualPosition * root.effectiveDraggingWidth) - (root.implicitHandleWidth / 2 + root.handleHorizontalMargins)
      color: root.highlightColor
      topLeftRadius: root.trackRadius
      bottomLeftRadius: root.trackRadius
      topRightRadius: Config.appearance.rounding.xxs
      bottomRightRadius: Config.appearance.rounding.xxs
    }

    Rectangle {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      implicitWidth: root.handleHorizontalMargins + ((1 - root.visualPosition) * root.effectiveDraggingWidth) - (root.implicitHandleWidth / 2 + root.handleHorizontalMargins)
      color: root.trackColor
      topRightRadius: root.trackRadius
      bottomRightRadius: root.trackRadius
      topLeftRadius: Config.appearance.rounding.xxs
      bottomLeftRadius: Config.appearance.rounding.xxs
    }

    Repeater {
      model: root.stopIndicatorValues

      TrackDot {
        required property real modelData

        value: modelData
        anchors.verticalCenter: parent.verticalCenter
      }
    }
  }

  handle: Rectangle {
    id: handle

    implicitWidth: root.pressed ? root.implicitPressedHandleWidth : root.implicitDefaultHandleWidth
    implicitHeight: root.implicitTrackHeight * 2
    x: root.handleHorizontalMargins + (root.visualPosition * root.effectiveDraggingWidth) - (implicitWidth / 2)
    anchors.verticalCenter: parent.verticalCenter
    radius: Config.appearance.rounding.full
    color: root.handleColor

    Behavior on implicitWidth {
      EffectNumberAnimation {}
    }

    ShinyTooltip {
      visible: root.pressed
      text: root.tooltipText
    }
  }
}
