pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.config

ShinyRectangle {
  id: root

  enum Type {
    Filled,
    Tonal,
    Outline
  }

  property int type: ShinyButton.Filled
  property string text: ""
  property real horizontalPadding: Config.appearance.padding.md
  property real verticalPadding: Config.appearance.padding.sm

  signal clicked
}
