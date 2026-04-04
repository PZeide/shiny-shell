pragma ComponentBehavior: Bound

import QtQuick
import qs.utils.animations

ShinyText {
  id: root

  property real animationDistanceX: 0
  property real animationDistanceY: 6

  Behavior on text {
    id: textAnimationBehavior

    property real originalX
    property real originalY

    SequentialAnimation {
      alwaysRunToEnd: true

      ParallelAnimation {
        SineInNumberAnimation {
          target: root
          property: "x"
          to: textAnimationBehavior.originalX - root.animationDistanceX
        }

        SineInNumberAnimation {
          target: root
          property: "y"
          to: textAnimationBehavior.originalY - root.animationDistanceY
        }

        SineInNumberAnimation {
          target: root
          property: "opacity"
          to: 0
        }
      }

      // Tie the text update to this point (we don't want it to happen during the first slide+fade)
      PropertyAction {}

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
        SineOutNumberAnimation {
          target: root
          property: "x"
          to: textAnimationBehavior.originalX
        }

        SineOutNumberAnimation {
          target: root
          property: "y"
          to: textAnimationBehavior.originalY
        }

        SineOutNumberAnimation {
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
