pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.components.controls
import qs.config
import qs.utils.animations

ShinyRectangle {
  id: root

  required property string icon
  required property string name

  readonly property real pressedOpacity: 0.18
  readonly property real focusedOpacity: 0.08

  readonly property bool mouseFocused: mouseArea.containsMouse
  readonly property bool focused: focus || mouseFocused

  property bool keyboardPressed: false
  readonly property bool pressed: keyboardPressed || mouseArea.containsPress

  signal invoked

  implicitWidth: 80
  implicitHeight: 80
  color: Config.appearance.color.surfaceContainer
  radius: Config.appearance.rounding.md
  border.color: focused || pressed ? Config.appearance.color.primary : "transparent"
  border.width: 1

  Behavior on border.color {
    EffectColorAnimation {}
  }

  Keys.onPressed: event => {
    if (event.key === Qt.Key_Return) {
      keyboardPressed = true;
      root.invoked();
      event.accepted = true;
    }
  }

  Keys.onReleased: event => {
    if (event.key === Qt.Key_Return) {
      keyboardPressed = false;
      event.accepted = true;
    }
  }

  ShinyIcon {
    anchors.centerIn: parent
    icon: root.icon
    font.pointSize: Config.appearance.font.size.xxl
    font.weight: Font.Medium
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    onPressed: root.invoked()
    onContainsMouseChanged: {
      if (containsMouse) {
        root.focus = true;
      }
    }
  }

  ShinyRectangle {
    id: layer
    anchors.fill: parent
    color: Config.appearance.color.primary
    opacity: root.pressed ? root.pressedOpacity : root.focused ? root.focusedOpacity : 0
    radius: root.radius

    Behavior on opacity {
      EffectNumberAnimation {}
    }
  }

  ShinyTooltip {
    visible: mouseArea.containsMouse
    text: root.name
  }
}
