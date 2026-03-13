pragma ComponentBehavior: Bound

import QtQuick
import qs.config

NumberAnimation {
  duration: Config.appearance.anim.durations.sm
  easing.type: Easing.BezierSpline
  easing.bezierCurve: Config.appearance.anim.curves.standardAccel
}
