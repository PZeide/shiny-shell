pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.config
import qs.utils.animations

TextArea {
  id: root

  property real radius: Config.appearance.rounding.sm

  color: Config.appearance.color.overSurface
  selectionColor: Config.appearance.color.surfaceVariant
  selectedTextColor: Config.appearance.color.overSurface
  placeholderTextColor: Config.appearance.color.outlineVariant
  cursorVisible: !readOnly
  renderType: Text.NativeRendering
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.md
  padding: 12

  cursorDelegate: ShinyRectangle {
    id: cursor

    property bool shouldBlink: true

    implicitWidth: 2
    color: root.color
    radius: Config.appearance.rounding.sm

    SequentialAnimation on opacity {
      running: root.activeFocus && root.cursorVisible && cursor.shouldBlink
      loops: Animation.Infinite

      StandardOutNumberAnimation {
        from: 1
        to: 0
      }

      PauseAnimation {
        duration: 200
      }

      StandardInNumberAnimation {
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
    color: Config.appearance.color.surfaceContainer
  }
}
