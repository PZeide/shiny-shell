pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.components
import qs.utils.animations

Item {
  id: root

  property alias contentItem: contentLayout.contentItem

  implicitHeight: parent.height
  implicitWidth: contentLayout.implicitWidth + contentLayout.anchors.leftMargin + contentLayout.anchors.rightMargin

  Behavior on implicitWidth {
    EffectNumberAnimation {}
  }

  Behavior on implicitHeight {
    EffectNumberAnimation {}
  }

  ShinyRectangle {
    anchors.fill: root
    color: Config.appearance.color.surfaceContainerHigh
    radius: Config.appearance.rounding.xs
  }

  Item {
    id: contentLayout

    default property Item contentItem

    onContentItemChanged: {
      if (contentItem) {
        contentItem.parent = contentLayout;
        contentItem.anchors.centerIn = contentLayout;
      }
    }

    anchors.centerIn: parent
    anchors.margins: Config.appearance.padding.xs
    implicitWidth: contentItem.implicitWidth
    implicitHeight: root.implicitHeight - anchors.topMargin - anchors.bottomMargin
  }
}
