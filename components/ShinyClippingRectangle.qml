pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.utils.animations

ClippingRectangle {
  color: "transparent"

  Behavior on color {
    EffectColorAnimation {}
  }
}
