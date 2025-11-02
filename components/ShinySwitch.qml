import QtQuick
import QtQuick.Controls
import qs.config
import qs.utils.animations

// From https://github.com/end-4/dots-hyprland/blob/main/dots/.config/quickshell/ii/modules/common/widgets/StyledSwitch.qml
Switch {
  id: root

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
    width: parent.width
    height: parent.height
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

  indicator: Rectangle {
    readonly property real indicatorSize: (root.pressed || root.down) ? 18 : root.checked ? 16 : 10

    width: indicatorSize
    height: indicatorSize
    radius: Config.appearance.rounding.full
    color: root.checked ? Config.appearance.color.overPrimary : Config.appearance.color.outline
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: root.checked ? ((root.pressed || root.down) ? 15 : 16) : ((root.pressed || root.down) ? 1 : 5)

    Behavior on anchors.leftMargin {
      StandardNumberAnimation {}
    }

    Behavior on width {
      StandardNumberAnimation {}
    }

    Behavior on height {
      StandardNumberAnimation {}
    }

    Behavior on color {
      StandardColorAnimation {}
    }
  }
}
