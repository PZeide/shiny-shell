pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.components
import qs.config

ShinyRectangle {
  id: root

  required property ShellScreen screen
  required property bool freeze
  required property bool snapWindows
  required property bool snapLayers
  readonly property HyprlandMonitor hyprlandMonitor: HyprCompositor.monitorFor(screen)

  readonly property list<Region> windowRegions: hyprlandMonitor.activeWorkspace?.toplevels.sort((a, b) => {
    if (a.lastIpcObject.floating !== b.lastIpcObject.floating) {
      return a.floating ? -1 : 1;
    }

    return a.floating ? -1 : 1;
  }) ?? []

  readonly property list<Region> layerRegions

  signal selected(region: string)
  signal cancelled

  color: Config.appearance.color.scrim

  Loader {
    anchors.fill: parent
    active: root.freeze
    sourceComponent: ScreencopyView {
      anchors.fill: parent
      live: false
      paintCursor: false
      captureSource: root.screen
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.CrossCursor

    onClicked: root.selected("dqdq")
  }

  Item {
    anchors.fill: parent
    focus: true

    Keys.onEscapePressed: root.cancelled()
  }
}
