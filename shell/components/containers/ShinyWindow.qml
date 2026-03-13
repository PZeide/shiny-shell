pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland

PanelWindow { // qmllint disable uncreatable-type
  required property string name

  WlrLayershell.namespace: `shiny:${name}`
  color: "transparent"
}
