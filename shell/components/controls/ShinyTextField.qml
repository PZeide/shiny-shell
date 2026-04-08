pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Shiny.Helpers
import qs.config
import qs.components
import qs.utils
import qs.utils.animations

T.TextField {
  id: root

  property icon sIcon: Helpers.emptyIcon()
  property alias sIconFont: icon.font
  readonly property bool hasIcon: sIcon.name !== ""
  property alias radius: backgroundRectangle.radius
  property alias topLeftRadius: backgroundRectangle.topLeftRadius
  property alias topRightRadius: backgroundRectangle.topRightRadius
  property alias bottomLeftRadius: backgroundRectangle.bottomLeftRadius
  property alias bottomRightRadius: backgroundRectangle.bottomRightRadius

  implicitWidth: 100 + leftPadding + rightPadding
  implicitHeight: 20 + topPadding + bottomPadding
  color: enabled ? Config.appearance.color.overSurface : Config.appearance.color.outline
  selectionColor: Config.appearance.color.surfaceVariant
  selectedTextColor: Config.appearance.color.overSurface
  placeholderTextColor: Config.appearance.color.outlineVariant
  cursorVisible: activeFocus
  renderType: Text.NativeRendering
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.md
  padding: Config.appearance.padding.lg
  leftPadding: hasIcon ? icon.width + icon.anchors.leftMargin + (padding / 2) : padding

  cursorDelegate: ShinyRectangle {
    id: cursor

    property bool shouldBlink: true

    implicitWidth: 2
    color: root.color
    radius: Config.appearance.rounding.sm

    SequentialAnimation on opacity {
      running: root.cursorVisible && cursor.shouldBlink
      loops: Animation.Infinite

      onStopped: cursor.opacity = 0
      onStarted: cursor.opacity = 1

      PauseAnimation {
        duration: 400
      }

      NumberAnimation {
        duration: 120
        easing.type: Easing.InQuad
        from: 1
        to: 0
      }

      PauseAnimation {
        duration: 400
      }

      NumberAnimation {
        duration: 200
        easing.type: Easing.OutQuad
        from: 0
        to: 1
      }
    }

    Timer {
      id: delayBlink
      interval: 300
      onTriggered: cursor.shouldBlink = true
    }

    Connections {
      target: root

      function onCursorPositionChanged(): void {
        if (root.cursorVisible) {
          cursor.opacity = 1;
          cursor.shouldBlink = false;
          delayBlink.restart();
        }
      }
    }

    Binding {
      when: !root.cursorVisible
      cursor.opacity: 0
    }
  }

  background: ShinyClippingRectangle {
    color: "transparent"
    topLeftRadius: backgroundRectangle.topLeftRadius
    topRightRadius: backgroundRectangle.topRightRadius
    bottomLeftRadius: backgroundRectangle.bottomLeftRadius
    bottomRightRadius: backgroundRectangle.bottomRightRadius

    ShinyRectangle {
      id: backgroundRectangle
      anchors.fill: parent
      radius: Config.appearance.rounding.xs

      color: {
        if (!root.enabled) {
          return Config.appearance.color.surfaceContainerLow;
        } else if (root.hovered || root.activeFocus) {
          return Config.appearance.color.surfaceContainerHigh;
        } else {
          return Config.appearance.color.surfaceContainer;
        }
      }
    }

    ShinyRectangle {
      id: indicator
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: root.activeFocus ? 2 : 1

      color: {
        if (!root.enabled) {
          return Config.appearance.color.outline;
        } else if (root.activeFocus) {
          return Config.appearance.color.primary;
        } else {
          return Config.appearance.color.overSurfaceVariant;
        }
      }

      Behavior on height {
        EffectNumberAnimation {}
      }
    }
  }

  ShinyIcon {
    id: icon
    visible: root.hasIcon
    icon: root.sIcon.name
    fill: root.sIcon.fill
    grade: root.sIcon.grade
    font.pointSize: Config.appearance.font.size.lg
    anchors.left: parent.left
    anchors.leftMargin: root.hasIcon ? root.padding : 0
    anchors.verticalCenter: parent.verticalCenter
    color: enabled ? Config.appearance.color.overSurfaceVariant : Config.appearance.color.outline
  }

  ShinyText {
    visible: root.text === ""
    anchors.left: parent.left
    anchors.leftMargin: root.leftPadding
    anchors.verticalCenter: parent.verticalCenter
    font: root.font
    text: root.placeholderText
    color: root.placeholderTextColor
  }
}
