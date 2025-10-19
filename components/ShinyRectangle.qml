pragma ComponentBehavior: Bound

import QtQuick
import qs.utils.animations

Rectangle {
  color: "transparent"

  Behavior on color {
    EffectColorAnimation {}
  }
}
