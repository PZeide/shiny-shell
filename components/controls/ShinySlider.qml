pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.config
import qs.components
import qs.utils.animations

Slider {
  id: root

  property string icon: ""
  property real iconSize: Config.appearance.font.size.lg

  from: 0
  to: 1

  background: ShinyRectangle {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - parent.height
    height: parent.height * 0.6
    radius: Config.appearance.rounding.md
    color: Config.appearance.color.surfaceVariant
  }

  ShinyRectangle {
    id: bar
    width: parent.height + root.visualPosition * (parent.width - parent.height)
    height: parent.height
    radius: Config.appearance.rounding.md
    color: Config.appearance.color.primary

    Behavior on width {
      EffectNumberAnimation {}
    }
  }

  handle: ShinyIcon {
    visible: root.icon !== ""
    icon: root.icon
    color: Config.appearance.color.overSurface
    font.pointSize: root.iconSize
    anchors.right: bar.right
    anchors.verticalCenter: bar.verticalCenter
    anchors.rightMargin: fontInfo.pixelSize / 3

    Behavior on x {
      EffectNumberAnimation {}
    }
  }
}
