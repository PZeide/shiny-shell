pragma ComponentBehavior: Bound

import QtQuick
import qs.config

ShinyText {
  required property string icon

  property real fill: 0 // https://fonts.google.com/knowledge/glossary/fill_axis
  property int grade: 0 // https://fonts.google.com/knowledge/glossary/grade_axis

  text: icon
  font.family: Config.appearance.font.family.iconMaterial
  font.hintingPreference: Font.PreferFullHinting
  font.variableAxes: {
    "FILL": fill.toFixed(2),
    "GRAD": grade,
    "opsz": fontInfo.pixelSize,
    "wght": fontInfo.weight
  }
}
