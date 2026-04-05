pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.components
import qs.config

ShinyRectangle {
  id: root

  required property ShellScreen screen
  readonly property HyprlandMonitor monitor: HyprCompositor.monitorFor(screen)
  // Rotation and flip state of monitor https://wayland-client-d.dpldocs.info/source/wayland.client.protocol.d.html#L3329
  readonly property int monitorTransform: monitor.lastIpcObject.transform ?? 0
  readonly property real monitorTransformedWidth: monitorTransform % 2 === 0 ? monitor.width : monitor.height
  readonly property real monitorTransformedHeight: monitorTransform % 2 === 0 ? monitor.height : monitor.width
  // Amount of space claimed and reserved by layers
  readonly property list<int> monitorReserved: monitor.lastIpcObject.reserved
  readonly property int horizontalReserved: monitorReserved[0] + monitorReserved[2]
  readonly property int verticalReserved: monitorReserved[1] + monitorReserved[3]

  readonly property int workspacesShown: Config.overview.rows * Config.overview.columns
  readonly property int workspaceGroup: Math.floor(((monitor.activeWorkspace.id ?? 1) - 1) / workspacesShown)

  readonly property real overviewWorkspaceWidth: ((root.monitorTransformedWidth - horizontalReserved) * Config.overview.scale / monitor.scale)
  readonly property real overviewWorkspaceHeight: ((root.monitorTransformedHeight - verticalReserved) * Config.overview.scale / monitor.scale)

  implicitWidth: layout.implicitWidth + Config.appearance.spacing.sm * 2
  implicitHeight: layout.implicitHeight + Config.appearance.spacing.sm * 2
  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

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
              HyprCompositor.dispatch(`workspace ${workspaceId}`);
              root.shouldClose();
            }

            onReceiveWindow: window => {
              HyprCompositor.dispatch(`movetoworkspacesilent ${workspaceId}, address:0x${window.address}`);
            }
          }
        }
      }
    }
  }

  // We use a different container for every windows to manage their z-order
  Item {
    id: windowContainer
    anchors.centerIn: parent
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ScriptModel {
      id: windowsModel
      values: HyprCompositor.toplevels.values.filter(window => {
        if (window === null || window.workspace === null || window.wayland === null) {
          return false;
        }

        if (!window.lastIpcObject.size || !window.lastIpcObject.at) {
          return false;
        }

        const shownLowerBound = root.workspaceGroup * root.workspacesShown + 1;
        const shownUpperBound = shownLowerBound + root.workspacesShown;
        // Check that id is in bounds
        if (window.workspace.id < shownLowerBound || window.workspace.id >= shownUpperBound) {
          return false;
        }

        return true;
      })
    }

    Repeater {
      model: windowsModel

      delegate: OverviewWindow {
        required property HyprlandToplevel modelData
        required property int index

        readonly property HyprlandWorkspace workspace: window.workspace

        readonly property int windowWidth: window.lastIpcObject.size[0]
        readonly property int windowHeight: window.lastIpcObject.size[1]
        readonly property int windowX: window.lastIpcObject.at[0]
        readonly property int windowY: window.lastIpcObject.at[1]
        readonly property real windowFocusHistory: window.lastIpcObject.focusHistoryID
        readonly property bool windowFloating: window.lastIpcObject.floating
        readonly property bool windowPinned: window.lastIpcObject.pinned

        readonly property int workspaceColumnIndex: (workspace.id - 1) % Config.overview.columns
        readonly property int workspaceRowIndex: Math.floor((workspace.id - 1) % root.workspacesShown / Config.overview.columns)
        readonly property real workspaceX: (root.overviewWorkspaceWidth + Config.appearance.spacing.xs) * workspaceColumnIndex
        readonly property real workspaceY: (root.overviewWorkspaceHeight + Config.appearance.spacing.xs) * workspaceRowIndex

        window: modelData
        // We apply a 'debuff' based on the focus history (bigger value = longer time since last focus so below)
        // We apply a 'buff' for the window if it's floating
        // We apply a 'buff' for the window if it's pinned
        windowZ: waylandWindow.fullscreen ? 5000 : 1000 - windowFocusHistory + (windowFloating ? 500 : 0) + (windowPinned ? 500 : 0)
        initialX: waylandWindow.fullscreen ? workspaceX : workspaceX + (windowX - root.monitor.x - root.monitor.lastIpcObject.reserved[0]) * Config.overview.scale
        initialY: waylandWindow.fullscreen ? workspaceY : workspaceY + (windowY - root.monitor.y - root.monitor.lastIpcObject.reserved[1]) * Config.overview.scale
        implicitWidth: waylandWindow.fullscreen ? root.overviewWorkspaceWidth : windowWidth * Config.overview.scale
        implicitHeight: waylandWindow.fullscreen ? root.overviewWorkspaceHeight : windowHeight * Config.overview.scale

        onShouldFocus: {
          HyprCompositor.dispatch(`focuswindow address:0x${window.address}`);
          root.shouldClose();
        }

        onShouldClose: HyprCompositor.dispatch(`closewindow address:0x${window.address}`)
      }
    }
  }

  component ModelRoleData: QtObject {
    property HyprlandToplevel modelData
  }
}
