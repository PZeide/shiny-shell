pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Config

Item {
  id: root

  required property ShellScreen screen
  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
  property list<HyprlandWorkspace> workspaces: []

  function updateWorkspaces() {
    workspaces = Hyprland.workspaces.values.filter(workspace => workspace.id > 0).filter(workspace => workspace.monitor === monitor);
    console.log(Hyprland.workspaces.values);
  }

  Component.onCompleted: updateWorkspaces()

  Connections {
    target: Hyprland.workspaces
    function onValuesChanged() {
      root.updateWorkspaces();
    }
  }

  WheelHandler {
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: event => {
      if (event.angleDelta.y < 0) {
        Hyprland.dispatch("workspace r+1");
      } else if (event.angleDelta.y > 0) {
        Hyprland.dispatch("workspace r-1");
      }
    }
  }

  RowLayout {
    id: rowLayout

    spacing: 0
    anchors.fill: parent

    Repeater {
      model: root.workspaces

      Rectangle {
        required property HyprlandWorkspace modelData

        implicitWidth: 26
        implicitHeight: 26
        radius: Config.appearance.rounding.full
        color: Qt.alpha("#ff0000", 0.4)
      }
    }
  }
}
