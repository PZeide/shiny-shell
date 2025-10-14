pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.widgets
import qs.config
import qs.utils
import qs.utils.animations

ShinyRectangle {
  id: root

  required property HyprlandToplevel window
  required property int windowZ
  required property real initialX
  required property real initialY

  readonly property real iconToWindowRatio: 0.35
  readonly property real iconToWindowRatioCompact: 0.6
  readonly property string windowIconPath: Icons.findFromClass(window.lastIpcObject.class)

  signal shouldFocus
  signal shouldClose

  x: initialX
  y: initialY
  z: Drag.active ? 99999 : windowZ
  color: "transparent"
  radius: Config.appearance.rounding.corner * Config.overview.scale

  Behavior on x {
    EffectNumberAnimation {}
  }

  Behavior on y {
    EffectNumberAnimation {}
  }

  Behavior on width {
    EffectNumberAnimation {}
  }

  Behavior on height {
    EffectNumberAnimation {}
  }

  ShinyClippingRectangle {
    anchors.fill: parent
    radius: root.radius

    ScreencopyView {
      id: screencopy

      anchors.fill: parent
      captureSource: root.window?.wayland ?? null
      live: true

      Image {
        property real iconSize: Math.min(root.implicitWidth, root.implicitHeight) * 0.4

        anchors.centerIn: parent
        source: root.windowIconPath
        width: iconSize
        height: iconSize
        sourceSize: Qt.size(iconSize, iconSize)
      }
    }
  }

  Drag.active: mouseArea.drag.active
  Drag.hotSpot.x: width / 2
  Drag.hotSpot.y: height / 2
  Drag.keys: ["window"]

  ShinyMouseArea {
    id: mouseArea

    layerRadius: root.radius
    anchors.fill: parent
    drag.target: parent
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onPressed: event => {
      root.Drag.hotSpot.x = event.x;
      root.Drag.hotSpot.y = event.y;
    }

    onReleased: {
      const action = root.Drag.drop();
      root.x = root.initialX;
      root.y = root.initialY;
    }

    onClicked: event => {
      event.accepted = true;
      if (event.button === Qt.LeftButton) {
        root.shouldFocus();
      } else if (event.button === Qt.MiddleButton) {
        root.shouldClose();
      }
    }
  }
}
