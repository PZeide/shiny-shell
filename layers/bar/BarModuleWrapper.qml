pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

ShinyRectangle {
  default property alias content: contentLayout.children

  anchors.top: parent.top
  anchors.bottom: parent.bottom
  anchors.topMargin: 3
  anchors.bottomMargin: 3
  implicitWidth: contentLayout.width + 12

  ShinyRectangle {
    anchors.fill: parent
    color: Config.appearance.color.bgSecondary
    radius: Config.appearance.rounding.xs
  }

  RowLayout {
    id: contentLayout
    anchors.centerIn: parent
  }
}
