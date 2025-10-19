pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import qs.components
import qs.config
import qs.utils
import qs.utils.animations

ShinyRectangle {
  id: root

  required property int workspaceId
  required property real workspaceX
  required property real workspaceY
  readonly property HyprlandWorkspace maybeWorkspace: Hyprland.workspaces.values.find(w => w.id === workspaceId)
  readonly property bool isActive: maybeWorkspace?.active ?? false

  readonly property bool hasForeignDrag: {
    if (!dropArea.containsDrag)
      return false;

    const source = dropArea.drag.source as OverviewWindow;
    return source.window.workspace?.id !== workspaceId;
  }

  signal workspaceClicked
  signal receiveWindow(window: HyprlandToplevel)

  color: Config.appearance.color.bgSecondary
  opacity: root.hasForeignDrag ? 0.6 : 1
  border.width: 2
  border.color: isActive ? Config.appearance.color.accentPrimary : "transparent"

  Behavior on opacity {
    EffectNumberAnimation {}
  }

  Behavior on border.color {
    EffectColorAnimation {}
  }

  ShinyText {
    anchors.centerIn: parent
    text: root.workspaceId
    color: Colors.transparentize(Config.appearance.color.fgPrimary, 0.8)
    font.pointSize: -1 // By default we use pointSize but here we want to use pixelSize so we reset pointSize to avoid a warning
    font.pixelSize: Math.min(root.implicitWidth, root.implicitHeight) * 0.55
    font.weight: Font.DemiBold
    font.family: Config.appearance.font.family.mono
  }

  ShinyMouseArea {
    id: mouseArea
    visible: !root.isActive
    layerRadius: root.radius
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton

    onPressed: root.workspaceClicked()
  }

  DropArea {
    id: dropArea
    anchors.fill: parent
    keys: ["window"]

    onDropped: event => {
      const source = event.source as OverviewWindow;
      root.receiveWindow(source.window);
    }
  }
}
