pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import qs.config
import qs.components
import qs.utils.animations

T.ScrollBar {
  id: root

  property real implicitDefaultSize: 3
  property real implicitHoveredSize: 5
  property real implicitPressedSize: 7
  readonly property real implicitSize: {
    if (root.pressed) {
      return root.implicitPressedSize;
    } else if (root.hovered) {
      return root.implicitHoveredSize;
    } else {
      return root.implicitDefaultSize;
    }
  }

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
  padding: Config.appearance.padding.xs
  visible: root.policy !== T.ScrollBar.AlwaysOff

  contentItem: ShinyRectangle {
    implicitWidth: root.implicitSize
    implicitHeight: root.implicitSize
    radius: Config.appearance.padding.sm
    color: root.pressed ? Config.appearance.color.primary : Config.appearance.color.overSurfaceVariant
    opacity: 0

    Behavior on implicitWidth {
      EffectNumberAnimation {}
    }

    Behavior on implicitHeight {
      EffectNumberAnimation {}
    }
  }

  states: State {
    name: "active"
    when: root.policy === T.ScrollBar.AlwaysOn || (root.active && root.size < 1.0)
  }

  transitions: [
    Transition {
      to: "active"
      EffectNumberAnimation {
        target: root.contentItem
        property: "opacity"
        to: 0.35
      }
    },
    Transition {
      from: "active"
      SequentialAnimation {
        PropertyAction {
          target: root.contentItem
          property: "opacity"
          value: 0.35
        }
        PauseAnimation {
          duration: 2450
        }
        EffectNumberAnimation {
          target: root.contentItem
          property: "opacity"
          to: 0
        }
      }
    }
  ]
}
