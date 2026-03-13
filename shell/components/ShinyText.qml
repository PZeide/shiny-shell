pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.utils.animations

Text {
  id: root

  renderType: Text.NativeRendering
  textFormat: Text.PlainText
  color: Config.appearance.color.overSurface
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.md

  Behavior on color {
    EffectColorAnimation {}
  }
}
