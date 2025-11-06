pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.utils.animations
import qs.config
import qs.utils

RectangularShadow {
  required property Item target

  property real size: 10

  anchors.fill: target
  radius: target.radius ?? 0
  blur: 0.9 * size
  spread: 1
  color: Colors.transparentize(Config.appearance.color.shadow, 0.5)
  cached: true

  Behavior on size {
    EffectNumberAnimation {}
  }
}
