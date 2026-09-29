pragma ComponentBehavior: Bound

import QtQuick
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
  readonly property int monitorWorkspacesCount: workspacesModel.values.length
  readonly property int activeWorkspaceIndex: workspacesModel.values.findIndex(workspace => workspace.active)

  readonly property real workspaceImplicitWidth: width - Config.appearance.padding.xs * 2
  readonly property real workspaceImplicitHeight: workspaceImplicitWidth
  readonly property real workspaceActiveImplicitHeight: workspaceImplicitHeight * 2
  readonly property real workspacesImplicitHeight: {
    if (monitorWorkspacesCount === 0) {
      return 0;
    }

    const spacingHeight = (monitorWorkspacesCount - 1) * Config.appearance.spacing.xs;
    const activeHeight = activeWorkspaceIndex >= 0 ? workspaceActiveImplicitHeight - workspaceImplicitHeight : 0;
    return monitorWorkspacesCount * workspaceImplicitHeight + spacingHeight + activeHeight;
  }

  ScriptModel {
    id: workspacesModel
    values: HyprCompositor.workspaces.values.filter(workspace => {
      return workspace.monitor === root.monitor && !workspace.address.startsWith("special:");
    }).sort((left, right) => Number(left.address) - Number(right.address))
  }

  contentItem: Item {
    id: layout
    anchors.centerIn: parent
    implicitWidth: root.workspaceImplicitWidth
    implicitHeight: root.workspacesImplicitHeight

    Repeater {
      model: workspacesModel

      delegate: ShinyRectangle {
        id: workspaceRectangle

        required property int index
        required property HyprlandWorkspace modelData

        readonly property bool isOccupied: modelData.toplevels.values.length > 0
        readonly property bool isActive: modelData.active

        property real targetCenterY: {
          const sp = Config.appearance.spacing.xs;
          const k = root.activeWorkspaceIndex;
          let yBefore = 0.0;

          for (let j = 0; j < index; j++) {
            yBefore += (j === k ? root.workspaceActiveImplicitHeight : root.workspaceImplicitHeight) + sp;
          }

          return yBefore + (index === k ? root.workspaceActiveImplicitHeight : root.workspaceImplicitHeight) / 2;
        }

        Behavior on targetCenterY {
          EffectNumberAnimation {}
        }

        width: root.workspaceImplicitWidth
        height: isActive ? root.workspaceActiveImplicitHeight : root.workspaceImplicitHeight
        x: 0
        y: targetCenterY - height / 2
        color: isActive ? Config.appearance.color.primary : Config.appearance.color.surfaceContainerHigh
        radius: Config.appearance.rounding.xxs

        Behavior on height {
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
          font.family: Config.bar.workspaces.showKanji ? Config.appearance.font.family.jp : Config.appearance.font.family.sans
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

          onPressed: workspaceRectangle.modelData.activate()
        }
      }
    }
  }
}
