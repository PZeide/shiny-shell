pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components
import qs.config
import qs.utils
import qs.utils.animations

ShinyRectangle {
  id: root

  required property HyprlandToplevel window
  required property int windowZ
  required property real initialX
  required property real initialY

  readonly property Toplevel waylandWindow: window.wayland
  readonly property string windowIconPath: Icons.findFromClass(waylandWindow.appId)

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
    color: root.waylandWindow.fullscreen ? Config.appearance.color.surface : "transparent"
    radius: root.radius

    ScreencopyView {
      id: screencopy
      anchors.fill: parent
      captureSource: root.waylandWindow
      live: true

      Image {
        anchors.centerIn: parent
        asynchronous: true
        sourceSize.width: Math.min(root.implicitWidth, root.implicitHeight) * 0.4
        sourceSize.height: Math.min(root.implicitWidth, root.implicitHeight) * 0.4
        source: root.windowIconPath
      }
    }
  }

  Drag.active: mouseArea.drag.active
  Drag.hotSpot.x: width / 2
  Drag.hotSpot.y: height / 2
  Drag.keys: ["window"]

  ShinyInteractiveLayer {
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
