pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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

  readonly property real workspaceImplicitWidth: width * 0.35

  readonly property real workspaceInoccupiedImplicitHeight: workspaceImplicitWidth
  readonly property real workspaceOccupiedImplicitHeight: workspaceImplicitWidth
  readonly property real workspaceActiveImplicitHeight: width * 0.65

  contentItem: Item {
    // Theoretically the max implicit height
    implicitHeight: root.workspaceActiveImplicitHeight + root.workspaceOccupiedImplicitHeight * (root.workspacesShown - 1) + layout.spacing * root.workspacesShown + Config.appearance.padding.xs * 2

    ColumnLayout {
      id: layout
      anchors.centerIn: parent
      spacing: Config.appearance.spacing.xs

      Repeater {
        model: root.workspacesShown

        delegate: ShinyRectangle {
          id: workspaceRectangle

          required property int index

          readonly property int workspaceId: root.workspaceGroup * root.workspacesShown + index + 1
          readonly property HyprlandWorkspace maybeWorkspace: Hyprland.workspaces.values.find(w => w.id === workspaceId) ?? null
          readonly property bool isOccupied: maybeWorkspace?.toplevels.values.length > 0
          readonly property bool isActive: maybeWorkspace?.active ?? false

          Layout.alignment: Qt.AlignHCenter
          implicitWidth: root.workspaceImplicitWidth
          implicitHeight: isActive ? root.workspaceActiveImplicitHeight : isOccupied ? root.workspaceOccupiedImplicitHeight : root.workspaceInoccupiedImplicitHeight
          color: isActive ? Config.appearance.color.primary : isOccupied ? Config.appearance.color.secondary : Config.appearance.color.surfaceBright
          radius: Config.appearance.rounding.full

          Behavior on implicitHeight {
            EffectNumberAnimation {}
          }

          Behavior on color {
            StandardColorAnimation {}
          }

          ShinyInteractiveLayer {
            visible: !workspaceRectangle.isActive
            anchors.fill: parent
            layerColor: workspaceRectangle.isOccupied ? Config.appearance.color.surface : Config.appearance.color.primary
            layerRadius: workspaceRectangle.radius
            clickOpacity: 0.45
            hoverOpacity: 0.25

            onPressed: Hyprland.dispatch(`workspace ${workspaceRectangle.workspaceId}`)
          }
        }
      }
    }
  }
}
