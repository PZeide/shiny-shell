pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates
import qs.config
import qs.components
import qs.utils.animations

// From https://github.com/end-4/dots-hyprland/blob/main/dots/.config/quickshell/ii/modules/common/widgets/StyledSwitch.qml
Switch {
  id: root

  property real implicitPressedIndicatorSize: implicitHeight - Math.min(2, implicitHeight / 10)
  property real implicitCheckedIndicatorSize: implicitHeight - Math.min(4, implicitHeight / 5)
  property real implicitIndicatorSize: implicitHeight / 2
  property color activeColor: Config.appearance.color.primary
  property color inactiveColor: Config.appearance.color.surfaceContainerHighest

  implicitHeight: 20
  implicitWidth: 34

  MouseArea {
    anchors.fill: parent
    onPressed: mouse => mouse.accepted = false
    cursorShape: Qt.PointingHandCursor
  }

  background: Rectangle {
    radius: Config.appearance.rounding.full
    color: root.checked ? root.activeColor : root.inactiveColor
    border.width: 1
    border.color: root.checked ? root.activeColor : Config.appearance.color.outline

    Behavior on color {
      StandardColorAnimation {}
    }

    Behavior on border.color {
      StandardColorAnimation {}
    }
  }

  indicator: ShinyRectangle {
    readonly property real indicatorSize: (root.pressed || root.down) ? root.implicitPressedIndicatorSize : root.checked ? root.implicitCheckedIndicatorSize : root.implicitIndicatorSize
    readonly property real leftMargin: (root.implicitHeight - root.implicitIndicatorSize) / 2
    readonly property real pressedLeftMargin: (root.implicitHeight - root.implicitPressedIndicatorSize) / 2
    readonly property real checkedLeftMargin: root.implicitWidth - root.implicitCheckedIndicatorSize - ((root.implicitHeight - root.implicitCheckedIndicatorSize) / 2)
    readonly property real checkedPressedLeftMargin: root.implicitWidth - root.implicitPressedIndicatorSize - pressedLeftMargin

    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: root.checked ? ((root.pressed || root.down) ? checkedPressedLeftMargin : checkedLeftMargin) : ((root.pressed || root.down) ? pressedLeftMargin : leftMargin)
    implicitWidth: indicatorSize
    implicitHeight: indicatorSize
    radius: Config.appearance.rounding.full
    color: root.checked ? Config.appearance.color.overPrimary : Config.appearance.color.outline

    Behavior on anchors.leftMargin {
      StandardNumberAnimation {}
    }

    Behavior on implicitWidth {
      StandardNumberAnimation {}
    }

    Behavior on implicitHeight {
      StandardNumberAnimation {}
    }

    Behavior on color {
      StandardColorAnimation {}
    }
  }
}
