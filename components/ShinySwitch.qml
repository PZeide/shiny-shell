import QtQuick
import QtQuick.Controls
import qs.config
import qs.utils.animations

// From https://github.com/end-4/dots-hyprland/blob/main/dots/.config/quickshell/ii/modules/common/widgets/StyledSwitch.qml
Switch {
  id: root

  property real scale: 0.6
  property color activeColor: Config.appearance.color.accentPrimary
  property color inactiveColor: Config.appearance.color.bgSecondary

  implicitHeight: 32 * root.scale
  implicitWidth: 52 * root.scale

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
    border.width: 2 * root.scale
    border.color: root.checked ? root.activeColor : Config.appearance.color.bgSelection

    Behavior on color {
      StandardColorAnimation {}
    }

    Behavior on border.color {
      StandardColorAnimation {}
    }
  }

  indicator: Rectangle {
    width: (root.pressed || root.down) ? (28 * root.scale) : root.checked ? (24 * root.scale) : (16 * root.scale)
    height: (root.pressed || root.down) ? (28 * root.scale) : root.checked ? (24 * root.scale) : (16 * root.scale)
    radius: Config.appearance.rounding.full
    color: root.checked ? Config.appearance.color.bgPrimary : Config.appearance.color.bgSelection
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: root.checked ? ((root.pressed || root.down) ? (22 * root.scale) : 24 * root.scale) : ((root.pressed || root.down) ? (2 * root.scale) : 8 * root.scale)

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
