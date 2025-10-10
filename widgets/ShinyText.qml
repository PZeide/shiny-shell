pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.utils.animations

Text {
  id: root

  property bool animateTextChange: false
  property real animationDistanceX: 0
  property real animationDistanceY: 6

  renderType: Text.NativeRendering
  textFormat: Text.PlainText
  color: Config.appearance.color.fgPrimary
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.md

  Behavior on color {
    EffectColorAnimation {}
  }

  Behavior on text {
    id: textAnimationBehavior

    property real originalX
    property real originalY

    enabled: root.animateTextChange

    SequentialAnimation {
      alwaysRunToEnd: true

      ParallelAnimation {
        SineEnterNumberAnimation {
          target: root
          property: "x"
          to: textAnimationBehavior.originalX - root.animationDistanceX
        }

        SineEnterNumberAnimation {
          target: root
          property: "y"
          to: textAnimationBehavior.originalY - root.animationDistanceY
        }

        SineEnterNumberAnimation {
          target: root
          property: "opacity"
          to: 0
        }
      }
      PropertyAction {} // Tie the text update to this point (we don't want it to happen during the first slide+fade)
      PropertyAction {
        target: root
        property: "x"
        value: textAnimationBehavior.originalX + root.animationDistanceX
      }
      PropertyAction {
        target: root
        property: "y"
        value: textAnimationBehavior.originalY + root.animationDistanceY
      }
      ParallelAnimation {
        SineLeaveNumberAnimation {
          target: root
          property: "x"
          to: textAnimationBehavior.originalX
        }

        SineLeaveNumberAnimation {
          target: root
          property: "y"
          to: textAnimationBehavior.originalY
        }

        SineLeaveNumberAnimation {
          target: root
          property: "opacity"
          to: 1
        }
      }
    }
  }

  Component.onCompleted: {
    textAnimationBehavior.originalX = root.x;
    textAnimationBehavior.originalY = root.y;
  }
}
