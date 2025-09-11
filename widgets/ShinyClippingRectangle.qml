pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.utils

ClippingRectangle {
  color: "transparent"

  Behavior on color {
    animation: Animations.effects.createColor(this)
  }
}
