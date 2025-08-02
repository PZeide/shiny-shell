pragma ComponentBehavior: Bound

import QtQuick
import qs.Config

MouseArea {
  id: root

  property color layerColor: Config.appearance.color.accentPrimary
  property int layerRadius: Config.appearance.rounding.md
  property real clickOpacity: 0.3
  property real hoverOpacity: 0.14

  hoverEnabled: true

  onContainsMouseChanged: {
    layer.opacity = (root.containsMouse) ? root.hoverOpacity : 0;
  }

  onContainsPressChanged: {
    layer.opacity = (root.containsPress) ? root.clickOpacity : root.hoverOpacity;
  }

  Rectangle {
    id: layer

    anchors.fill: parent
    color: root.layerColor
    opacity: 0
    radius: root.layerRadius

    Behavior on opacity {
      NumberAnimation {
        duration: Config.appearance.anim.durations.md
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Config.appearance.anim.curves.standard
      }
    }
  }
}
