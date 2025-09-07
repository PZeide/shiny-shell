pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.Config

ClippingRectangle {
  color: "transparent"

  Behavior on color {
    ColorAnimation {
      duration: Config.appearance.anim.durations.md
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Config.appearance.anim.curves.standard
    }
  }
}
