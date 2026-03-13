pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.config
import qs.utils

RectangularShadow {
  required property Item target

  readonly property real topSize: blur - offset.y + spread
  readonly property real bottomSize: blur + offset.y + spread
  readonly property real leftSize: blur - offset.x + spread
  readonly property real rightSize: blur + offset.x + spread
  readonly property real horizontalSize: leftSize + rightSize
  readonly property real verticalSize: topSize + bottomSize

  anchors.fill: target
  cached: true
  radius: target instanceof Rectangle ? (target as Rectangle).radius : 0
  blur: 10
  spread: 1
  color: Colors.transparentize(Config.appearance.color.shadow, 0.5)
}
