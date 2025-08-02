pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

Rectangle {
  color: "transparent"

  Behavior on color {
    ColorAnimation {
      duration: Config.appearance.anim.durations.md
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Config.appearance.anim.curves.standard
    }
  }
}
