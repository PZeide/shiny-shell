pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.components
import qs.utils.animations
import qs.layers.bar

BarModuleWrapper {
  id: root

  required property ShellScreen screen

  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
  readonly property int monitorWorkspacesCount: Hyprland.workspaces.values.filter(w => w.monitor == monitor && w.id >= 0).length

  readonly property int workspacesShown: Config.bar.workspaces.count > 0 ? Config.bar.workspaces.count : monitorWorkspacesCount
  readonly property int workspaceGroup: Math.floor(((monitor.activeWorkspace?.id ?? 1) - 1) / Config.bar.workspaces.count)
  readonly property int size: height * 0.45

  Repeater {
    model: root.workspacesShown

    delegate: ShinyRectangle {
      id: workspaceRectangle

      required property int index

      readonly property int workspaceId: root.workspaceGroup * root.workspacesShown + index + 1
      readonly property HyprlandWorkspace maybeWorkspace: Hyprland.workspaces.values.find(w => w.id === workspaceId) ?? null
      readonly property bool isOccupied: maybeWorkspace?.toplevels.values.length > 0
      readonly property bool isActive: maybeWorkspace?.active ?? false

      implicitWidth: isActive ? root.size * 2.5 : isOccupied ? root.size * 0.8 : root.size * 0.6
      implicitHeight: isActive ? root.size : isOccupied ? root.size * 0.8 : root.size * 0.6
      color: isActive ? Config.appearance.color.primary : isOccupied ? Config.appearance.color.secondary : Config.appearance.color.surfaceBright
      radius: Config.appearance.rounding.full

      Behavior on implicitWidth {
        StandardNumberAnimation {}
      }

      Behavior on implicitHeight {
        StandardNumberAnimation {}
      }

      Behavior on color {
        StandardColorAnimation {}
      }

      ShinyMouseArea {
        visible: !workspaceRectangle.isActive
        anchors.fill: parent
        layerColor: workspaceRectangle.isOccupied ? Config.appearance.color.surface : Config.appearance.color.primary
        layerRadius: workspaceRectangle.radius
        clickOpacity: 0.45
        hoverOpacity: 0.25
        acceptedButtons: Qt.LeftButton

        onPressed: event => {
          event.accepted = true;
          Hyprland.dispatch(`workspace ${workspaceRectangle.workspaceId}`);
        }
      }
    }
  }
}
