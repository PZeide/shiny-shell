pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland

PanelWindow {
  required property string name

  WlrLayershell.namespace: `shiny-${name}`
  color: "transparent"
}
