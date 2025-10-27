pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.config

ShinyRectangle {
  id: root

  required property ShellScreen screen

  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
  // Rotation and flip state of monitor https://wayland-client-d.dpldocs.info/source/wayland.client.protocol.d.html#L3329
  readonly property int monitorTransform: monitor.lastIpcObject.transform ?? 0
  readonly property real monitorTransformedWidth: monitorTransform % 2 === 0 ? monitor.width : monitor.height
  readonly property real monitorTransformedHeight: monitorTransform % 2 === 0 ? monitor.height : monitor.width
  // Amount of space claimed and reserved by layers
  readonly property list<int> monitorReserved: monitor.lastIpcObject.reserved ?? [0, 0, 0, 0]
  readonly property int horizontalReserved: monitorReserved[0] + monitorReserved[2]
  readonly property int verticalReserved: monitorReserved[1] + monitorReserved[3]

  readonly property int workspacesShown: Config.overview.rows * Config.overview.columns
  readonly property int workspaceGroup: Math.floor(((monitor.activeWorkspace?.id ?? 1) - 1) / workspacesShown)

  readonly property real overviewWorkspaceWidth: ((root.monitorTransformedWidth - horizontalReserved) * Config.overview.scale / monitor.scale)
  readonly property real overviewWorkspaceHeight: ((root.monitorTransformedHeight - verticalReserved) * Config.overview.scale / monitor.scale)

  implicitWidth: layout.implicitWidth + Config.appearance.spacing.xs * 2
  implicitHeight: layout.implicitHeight + Config.appearance.spacing.xs * 2
  color: Config.appearance.color.surface

  signal shouldClose

  Column {
    id: layout
    anchors.centerIn: parent
    spacing: Config.appearance.spacing.xs

    Repeater {
      model: Config.overview.rows

      delegate: Row {
        id: row

        required property int index

        spacing: Config.appearance.spacing.xs
        Repeater {
          model: Config.overview.columns

          delegate: OverviewWorkspace {
            id: cell

            required property int index

            workspaceId: root.workspaceGroup * root.workspacesShown + row.index * Config.overview.columns + cell.index + 1
            workspaceX: (root.overviewWorkspaceWidth + Config.appearance.spacing.xs) * cell.index
            workspaceY: (root.overviewWorkspaceHeight + Config.appearance.spacing.xs) * row.index
            implicitWidth: root.overviewWorkspaceWidth
            implicitHeight: root.overviewWorkspaceHeight
            radius: Config.appearance.rounding.corner * Config.overview.scale

            onWorkspaceClicked: {
              Hyprland.dispatch(`workspace ${workspaceId}`);
              root.shouldClose();
            }

            onReceiveWindow: window => {
              Hyprland.dispatch(`movetoworkspacesilent ${workspaceId}, address:0x${window.address}`);
            }
          }
        }
      }
    }
  }

  component ModelRoleData: QtObject {
    property HyprlandToplevel modelData
  }

  // We use a different container for every windows to manage their z-order
  Item {
    id: windowContainer
    anchors.centerIn: parent
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Connections {
      target: Hyprland

      function onRawEvent() {
        windowsModel.invalidate();
      }
    }

    SortFilterProxyModel {
      id: windowsModel
      model: Hyprland.toplevels

      filters: [
        FunctionFilter {
          function filter(data: ModelRoleData): bool {
            if (data.modelData === null || data.modelData.workspace === null) {
              return false;
            }

            const shownLowerBound = root.workspaceGroup * root.workspacesShown + 1;
            const shownUpperBound = shownLowerBound + root.workspacesShown;
            // Check that id is in bounds
            if (data.modelData.workspace.id < shownLowerBound || data.modelData.workspace.id >= shownUpperBound) {
              return false;
            }

            // Check that lastIpcObject is actually valid
            if (!data.modelData.lastIpcObject.size || !data.modelData.lastIpcObject.at) {
              return false;
            }

            return true;
          }
        }
      ]
    }

    Repeater {
      model: windowsModel

      delegate: OverviewWindow {
        required property HyprlandToplevel modelData
        required property int index

        readonly property HyprlandWorkspace workspace: window?.workspace ?? null

        readonly property int windowWidth: window?.lastIpcObject.size[0] ?? 0
        readonly property int windowHeight: window?.lastIpcObject.size[1] ?? 0
        readonly property int windowX: window?.lastIpcObject.at[0] ?? 0
        readonly property int windowY: window?.lastIpcObject.at[1] ?? 0
        readonly property real windowFocusHistory: window?.lastIpcObject.focusHistoryID ?? 0
        readonly property bool windowFloating: window?.lastIpcObject.floating ?? false
        readonly property bool windowPinned: window?.lastIpcObject.pinned ?? false

        readonly property int workspaceColumnIndex: (workspace?.id - 1) % Config.overview.columns
        readonly property int workspaceRowIndex: Math.floor((workspace?.id - 1) % root.workspacesShown / Config.overview.columns)
        readonly property real workspaceX: (root.overviewWorkspaceWidth + Config.appearance.spacing.xs) * workspaceColumnIndex
        readonly property real workspaceY: (root.overviewWorkspaceHeight + Config.appearance.spacing.xs) * workspaceRowIndex

        window: modelData
        windowFullscreen: (window?.lastIpcObject.fullscreen ?? 0) > 1
        // We apply a 'debuff' based on the focus history (bigger value = longer time since last focus so below)
        // We apply a 'buff' for the window if it's floating
        // We apply a 'buff' for the window if it's pinned
        windowZ: windowFullscreen ? 5000 : 1000 - windowFocusHistory + (windowFloating ? 500 : 0) + (windowPinned ? 500 : 0)
        initialX: windowFullscreen ? workspaceX : workspaceX + (windowX - root.monitor.x - root.monitor.lastIpcObject.reserved[0]) * Config.overview.scale
        initialY: windowFullscreen ? workspaceY : workspaceY + (windowY - root.monitor.y - root.monitor.lastIpcObject.reserved[1]) * Config.overview.scale
        implicitWidth: windowFullscreen ? root.overviewWorkspaceWidth : windowWidth * Config.overview.scale
        implicitHeight: windowFullscreen ? root.overviewWorkspaceHeight : windowHeight * Config.overview.scale

        onShouldFocus: {
          Hyprland.dispatch(`focuswindow address:0x${window.address}`);
          root.shouldClose();
        }

        onShouldClose: Hyprland.dispatch(`closewindow address:0x${window.address}`)
      }
    }
  }
}
