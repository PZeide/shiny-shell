pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.components
import qs.utils
import qs.utils.animations
import qs.layers.bar

BarModuleWrapper {
  id: root

  required property ShellScreen screen

  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
  readonly property int monitorWorkspacesCount: Hyprland.workspaces.values.filter(w => w.monitor == monitor && w.id >= 0).length

  readonly property int workspacesShown: Config.bar.workspaces.count > 0 ? Config.bar.workspaces.count : monitorWorkspacesCount
  readonly property int workspaceGroup: Math.floor(((monitor.activeWorkspace?.id ?? 1) - 1) / Config.bar.workspaces.count)

  Row {
    id: row
    spacing: Config.bar.workspaces.spacing

    Repeater {
      model: root.workspacesShown

      delegate: ShinyRectangle {
        id: workspaceRectangle

        required property int index

        readonly property int workspaceId: root.workspaceGroup * root.workspacesShown + index + 1
        readonly property HyprlandWorkspace maybeWorkspace: Hyprland.workspaces.values.find(w => w.id === workspaceId) ?? null
        readonly property bool isOccupied: maybeWorkspace?.toplevels.values.length > 0
        readonly property bool isActive: maybeWorkspace?.active ?? false

        anchors.verticalCenter: row.verticalCenter
        width: isActive ? Config.bar.workspaces.size * 2.5 : isOccupied ? Config.bar.workspaces.size * 0.8 : Config.bar.workspaces.size * 0.6
        height: isActive ? Config.bar.workspaces.size : isOccupied ? Config.bar.workspaces.size * 0.8 : Config.bar.workspaces.size * 0.6
        color: isActive ? Config.appearance.color.accentPrimary : isOccupied ? Config.appearance.color.accentSecondary : Colors.transparentize(Config.appearance.color.fgPrimary, 0.8)
        radius: Config.appearance.rounding.full

        Behavior on width {
          EffectNumberAnimation {
            duration: Config.appearance.anim.durations.expressiveEffect * 2
          }
        }

        Behavior on height {
          EffectNumberAnimation {
            duration: Config.appearance.anim.durations.expressiveEffect * 2
          }
        }

        Behavior on color {
          EffectColorAnimation {
            duration: Config.appearance.anim.durations.expressiveEffect * 2
          }
        }

        ShinyMouseArea {
          visible: !workspaceRectangle.isActive
          anchors.fill: parent
          layerColor: workspaceRectangle.isOccupied ? Config.appearance.color.bgPrimary : Config.appearance.color.accentPrimary
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
}
