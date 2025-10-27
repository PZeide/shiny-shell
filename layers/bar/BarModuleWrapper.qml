pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

ShinyRectangle {
  id: root

  default property alias content: contentLayout.children

  property int contentSpacing: Config.appearance.spacing.xs

  anchors.top: parent.top
  anchors.bottom: parent.bottom
  anchors.topMargin: Config.appearance.spacing.xxs
  anchors.bottomMargin: Config.appearance.spacing.xxs
  implicitWidth: contentLayout.width + Config.appearance.padding.sm * 2

  ShinyRectangle {
    anchors.fill: parent
    color: Config.appearance.color.surfaceContainer
    radius: Config.appearance.rounding.xs
  }

  RowLayout {
    id: contentLayout
    anchors.centerIn: parent
    spacing: root.contentSpacing
  }
}
