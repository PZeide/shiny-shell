pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.config
import qs.utils

RectangularShadow {
  required property Item target
  readonly property real topPadding: blur - offset.y + spread
  readonly property real bottomPadding: blur + offset.y + spread
  readonly property real leftPadding: blur - offset.x + spread
  readonly property real rightPadding: blur + offset.x + spread
  readonly property real horizontalPadding: leftPadding + rightPadding
  readonly property real verticalPadding: topPadding + bottomPadding

  anchors.fill: target
  cached: true
  topLeftRadius: target instanceof Rectangle ? (target as Rectangle).topLeftRadius : 0
  topRightRadius: target instanceof Rectangle ? (target as Rectangle).topRightRadius : 0
  bottomLeftRadius: target instanceof Rectangle ? (target as Rectangle).bottomLeftRadius : 0
  bottomRightRadius: target instanceof Rectangle ? (target as Rectangle).bottomRightRadius : 0
  blur: 10
  spread: 1
  color: Colors.transparentize(Config.appearance.color.shadow, 0.5)
}
