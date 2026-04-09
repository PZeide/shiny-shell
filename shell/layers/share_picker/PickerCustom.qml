pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.components

ShinyRectangle {
  color: Config.appearance.color.surfaceContainer

  ShinyText {
    anchors.centerIn: parent
    font.pointSize: Config.appearance.font.size.lg
    text: "Please select the desired region with the on-screen picker"
  }
}
