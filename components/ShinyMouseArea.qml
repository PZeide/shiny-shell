pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.utils.animations

MouseArea {
  id: root

  property color layerColor: Config.appearance.color.inverseSurface
  property int layerRadius: Config.appearance.rounding.md
  property real clickOpacity: 0.18
  property real hoverOpacity: 0.08

  hoverEnabled: true

  onContainsMouseChanged: layer.opacity = (root.containsMouse) ? root.hoverOpacity : 0
  onContainsPressChanged: layer.opacity = (root.containsPress) ? root.clickOpacity : root.hoverOpacity

  ShinyRectangle {
    id: layer
    anchors.fill: parent
    color: root.layerColor
    opacity: 0
    radius: root.layerRadius

    Behavior on opacity {
      EffectNumberAnimation {}
    }
  }
}
