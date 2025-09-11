pragma ComponentBehavior: Bound

import QtQuick
import qs.utils

Rectangle {
  color: "transparent"

  Behavior on color {
    animation: Animations.effects.createColor(this)
  }
}
