pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.config
import qs.utils
import qs.utils.animations

TextField {
  id: root

  readonly property bool hasIcon: icon !== ""
  property string icon: ""
  property color iconColor: Config.appearance.color.fgSecondary
  property real iconSize: Config.appearance.font.size.lg
  property real radius: Config.appearance.rounding.sm

  color: Config.appearance.color.fgSecondary
  selectionColor: Config.appearance.color.bgSelection
  selectedTextColor: Config.appearance.color.fgSecondary
  placeholderTextColor: Colors.transparentize(Config.appearance.color.fgSecondary, 0.4)
  cursorVisible: !readOnly
  renderType: Text.NativeRendering
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.md
  padding: 12
  leftPadding: hasIcon ? iconSize + 25 : 0

  cursorDelegate: ShinyRectangle {
    id: cursor

    property bool shouldBlink: true

    implicitWidth: 2
    color: root.color
    radius: Config.appearance.rounding.sm

    SequentialAnimation on opacity {
      running: root.activeFocus && root.cursorVisible && cursor.shouldBlink
      loops: Animation.Infinite

      MoveExitNumberAnimation {
        from: 1
        to: 0
      }

      PauseAnimation {
        duration: 200
      }

      MoveEnterNumberAnimation {
        from: 0
        to: 1
      }
    }

    Timer {
      id: delayBlink

      interval: 500
      onTriggered: cursor.shouldBlink = true
    }

    Connections {
      target: root

      function onCursorPositionChanged(): void {
        if (root.activeFocus && root.cursorVisible) {
          cursor.opacity = 1;
          cursor.shouldBlink = false;
          delayBlink.restart();
        }
      }
    }

    Binding {
      when: !root.activeFocus || !root.cursorVisible
      cursor.opacity: 0
    }
  }

  background: ShinyRectangle {
    radius: root.radius
    color: Config.appearance.color.bgSecondary
  }

  ShinyIcon {
    visible: root.hasIcon
    icon: root.icon
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    font.pointSize: root.iconSize
    color: root.iconColor
    leftPadding: root.hasIcon ? 12 : 0
  }
}
