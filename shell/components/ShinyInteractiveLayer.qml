pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.utils.animations

MouseArea {
  id: root

  property alias layerColor: layer.color
  property alias layerRadius: layer.radius
  property real clickOpacity: 0.18
  property real hoverOpacity: 0.08

  hoverEnabled: true
  acceptedButtons: Qt.LeftButton

  onContainsMouseChanged: layer.opacity = (root.containsMouse) ? root.hoverOpacity : 0
  onContainsPressChanged: layer.opacity = (root.containsPress) ? root.clickOpacity : root.hoverOpacity

  ShinyRectangle {
    id: layer
    anchors.fill: parent
    color: Config.appearance.color.inverseSurface
    radius: root.parent instanceof Rectangle ? (root.parent as Rectangle).radius : 0
    opacity: 0

    Behavior on opacity {
      EffectNumberAnimation {}
    }
  }
}
