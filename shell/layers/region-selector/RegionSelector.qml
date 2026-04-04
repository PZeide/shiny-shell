pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Polkit
import qs.config
import qs.components
import qs.components.misc
import qs.components.containers
import qs.utils.animations

ShinyLayerAnimationHelper {
  id: root

  property real layerOpacity: 0

  enter: Transition {
    EffectNumberAnimation {
      target: root
      property: "layerOpacity"
      from: root.layerOpacity
      to: 0.45
    }
  }

  exit: Transition {
    EffectNumberAnimation {
      target: root
      property: "layerOpacity"
      from: root.layerOpacity
      to: 0
    }
  }

  function updateNotificationWindow() {
    if (Hyprland.focusedMonitor) {
      const shellScreen = Quickshell.screens.find(s => s.name == Hyprland.focusedMonitor.name);
      if (shellScreen) {
        root.notificationWindow = shellScreen;
      } else {
        console.warn(`No shell screen found for focused monitor ${Hyprland.focusedMonitor.name}`);
        root.notificationWindow = Quickshell.screens[0];
      }
    } else {
      console.warn("No focused monitor found");
      root.notificationWindow = Quickshell.screens[0];
    }
  }

  Loader {
    active: root.shown

    sourceComponent: Variants {
      id: variant
      model: Quickshell.screens

      delegate: ShinyWindow {
        id: window

        required property ShellScreen modelData

        name: "polkit"
        screen: modelData
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitWidth: screen.width
        implicitHeight: screen.height
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.notificationWindow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        ShortcutInhibitor {
          window: window
          enabled: root.notificationWindow == window.modelData
        }

        ShinyRectangle {
          anchors.fill: parent
          color: Config.appearance.color.scrim
          opacity: root.layerOpacity
        }

        Loader {
          anchors.centerIn: parent
          active: root.notificationWindow == window.modelData

          sourceComponent: PolkitDialog {
            flow: agent.flow
            opacity: root.notificationOpacity
            scale: root.notificationScale

            Component.onCompleted: focusField()
          }
        }
      }
    }
  }
}
