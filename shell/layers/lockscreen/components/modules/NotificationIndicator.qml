pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components
import qs.components.controls
import qs.layers.lockscreen.components as LockComponents

LockComponents.SystemModuleWrapper {
  id: root

  readonly property string tooltipText: {
    if (Notifications.dnd) {
      return "Do not disturb mode is on";
    }

    if (Notifications.all.count > 0) {
      return `You have ${Notifications.all.count} unread notifications`;
    }

    return "You have no unread notifications";
  }

  ShinyInteractiveLayer {
    id: layer
    anchors.fill: parent
    layerRadius: Config.appearance.rounding.xs

    onPressed: Notifications.dnd = !Notifications.dnd
  }

  ShinyTooltip {
    visible: layer.containsMouse && root.tooltipText !== ""
    text: root.tooltipText
  }

  contentItem: Item {
    implicitWidth: parent.implicitHeight

    ShinyIcon {
      anchors.centerIn: parent
      icon: Notifications.icon
      font.pointSize: Config.appearance.font.size.lg
    }
  }
}
