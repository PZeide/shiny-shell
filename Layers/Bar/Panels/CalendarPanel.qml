pragma ComponentBehavior: Bound

import Quickshell
import qs.Widgets

ShinyWindow {
  name: "calendar-panel"
  screen: root.screen
  anchors.top: timeModule.bottom
  margins.top: -Config.bar.bottomMargin
  exclusionMode: ExclusionMode.Normal
  width: 100
  height: 300

  ShinyRectangle {
    implicitWidth: 100
    implicitHeight: 300

    color: "red"
  }
}
