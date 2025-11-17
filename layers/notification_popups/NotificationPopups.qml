pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.config

Scope {
  id: root

  readonly property ShellScreen focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
  property bool inhibitClose: false

  PopupsLayer {
    id: layer
    screen: root.focusedScreen

    Component.onCompleted: layer.openLayer()
  }
}
