pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.config
import qs.components
import qs.utils.animations
import qs.layers.bar
import qs.utils

BarModuleWrapper {
  id: root

  required property ShellScreen screen

  readonly property HyprlandMonitor monitor: HyprCompositor.monitorFor(screen)
  readonly property int monitorWorkspacesCount: HyprCompositor.workspaces.values.filter(w => w.monitor == monitor && w.id >= 0).length
  readonly property int workspaceGroup: Math.floor((monitor.activeWorkspace?.id - 1 ?? 1) / monitorWorkspacesCount)

  readonly property real workspaceImplicitWidth: width - Config.appearance.padding.xs * 2
  readonly property real workspaceImplicitHeight: workspaceImplicitWidth
  readonly property real workspaceActiveImplicitHeight: workspaceImplicitHeight * 2

  contentItem: ColumnLayout {
    id: layout
    anchors.centerIn: parent
    spacing: Config.appearance.spacing.xs

    Repeater {
      model: root.monitorWorkspacesCount

      delegate: ShinyRectangle {
        id: workspaceRectangle

        required property int index

        readonly property int workspaceId: root.workspaceGroup * root.monitorWorkspacesCount + index + 1
        readonly property HyprlandWorkspace maybeWorkspace: HyprCompositor.workspaces.values.find(w => w.id === workspaceId) ?? null
        readonly property bool isOccupied: maybeWorkspace?.toplevels.values.length > 0
        readonly property bool isActive: maybeWorkspace?.active ?? false

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.workspaceImplicitWidth
        Layout.preferredHeight: isActive ? root.workspaceActiveImplicitHeight : root.workspaceImplicitHeight
        color: isActive ? Config.appearance.color.primary : Config.appearance.color.surfaceContainerHigh
        radius: Config.appearance.rounding.xxs

        Behavior on Layout.preferredHeight {
          EffectNumberAnimation {}
        }

        ShinyText {
          anchors.fill: parent
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          opacity: workspaceRectangle.isOccupied ? 1 : 0
          text: Config.bar.workspaces.showKanji ? Formatting.numberToKanji(workspaceRectangle.index + 1) : String(workspaceRectangle.index + 1)
          font.pointSize: Config.appearance.font.size.xs
          font.weight: Font.DemiBold
          color: workspaceRectangle.isActive ? Config.appearance.color.overPrimary : Config.appearance.color.overSurface

          Behavior on opacity {
            EffectNumberAnimation {}
          }
        }

        ShinyRectangle {
          anchors.centerIn: parent
          opacity: workspaceRectangle.isOccupied ? 0 : 1
          width: root.workspaceImplicitWidth * 0.2
          height: root.workspaceImplicitWidth * 0.2
          radius: Config.appearance.rounding.full
          color: workspaceRectangle.isActive ? Config.appearance.color.overPrimary : Config.appearance.color.surfaceBright

          Behavior on opacity {
            EffectNumberAnimation {}
          }
        }

        ShinyInteractiveLayer {
          visible: !workspaceRectangle.isActive
          anchors.fill: parent
          layerColor: Config.appearance.color.primary
          layerRadius: workspaceRectangle.radius
          clickOpacity: 0.45
          hoverOpacity: 0.25

          onPressed: HyprCompositor.dispatch(`workspace ${workspaceRectangle.workspaceId}`)
        }
      }
    }
  }
}
