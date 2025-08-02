pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

Text {
  renderType: Text.NativeRendering
  textFormat: Text.PlainText
  color: Config.appearance.color.fgPrimary
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.md

  Behavior on color {
    ColorAnimation {
      duration: Config.appearance.anim.durations.md
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Config.appearance.anim.curves.standard
    }
  }
}
