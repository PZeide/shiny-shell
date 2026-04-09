pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.components
import qs.utils.animations

Item {
  id: root

  property alias contentItem: contentLayout.contentItem

  implicitHeight: contentLayout.implicitHeight + contentLayout.anchors.topMargin + contentLayout.anchors.bottomMargin
  implicitWidth: parent.width

  ShinyRectangle {
    anchors.fill: root
    color: Config.appearance.color.surfaceContainer
    radius: Config.appearance.rounding.xs
  }

  Behavior on implicitWidth {
    EffectNumberAnimation {}
  }

  Behavior on implicitHeight {
    EffectNumberAnimation {}
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
    implicitWidth: root.implicitWidth - anchors.leftMargin - anchors.rightMargin
    implicitHeight: contentItem.implicitHeight
  }
}
