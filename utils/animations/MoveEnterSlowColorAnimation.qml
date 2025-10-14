pragma ComponentBehavior: Bound

import QtQuick
import qs.config

ColorAnimation {
  duration: Config.appearance.anim.durations.lg
  easing.type: Easing.BezierSpline
  easing.bezierCurve: Config.appearance.anim.curves.standardDecel
}
