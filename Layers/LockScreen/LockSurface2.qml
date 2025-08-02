pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import qs.Config
import qs.Services
import qs.Widgets

WlSessionLockSurface {
  id: root

  required property WlSessionLock sessionLock

  readonly property int animateInDuration: Config.appearance.anim.durations.lg
  readonly property int animateOutDuration: Config.appearance.anim.durations.lg
  property bool animatingIn: false
  property bool ready: false
  property bool animatingOut: false

  color: "transparent"

  Loader {
    active: Config.wallpaper.enabled
    anchors.fill: parent

    sourceComponent: Background {
      id: background

      source: Config.wallpaper.path
      opacity: 0

      Behavior on opacity {
        NumberAnimation {
          duration: root.animatingIn ? root.animateInDuration : root.animateOutDuration
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Config.appearance.anim.curves.standard
        }
      }

      layer.enabled: true
      layer.effect: MultiEffect {
        id: backgroundEffect

        blurEnabled: true

        NumberAnimation on blur {
          running: root.ready
          duration: Config.appearance.anim.durations.lg
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Config.appearance.anim.curves.standard
          from: 0
          to: 0.8
        }
      }

      Connections {
        target: root

        function onAnimatingInChanged() {
          if (root.animatingIn) {
            background.opacity = 1;
          }
        }

        function onAnimatingOutChanged() {
          if (root.animatingOut) {
            background.opacity = 0;
          }
        }
      }
    }
  }

  Loader {
    active: Config.wallpaper.enabled && Config.wallpaper.foreground && Foreground.canShow
    anchors.fill: parent

    sourceComponent: Background {
      id: foreground

      source: Foreground.path
      opacity: 0

      Behavior on opacity {
        NumberAnimation {
          duration: root.animatingIn ? root.animateInDuration : root.animateOutDuration
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Config.appearance.anim.curves.standard
        }
      }

      Connections {
        target: root

        function onAnimatingInChanged() {
          if (root.animatingIn) {
            foreground.opacity = 1;
          }
        }

        function onAnimatingOutChanged() {
          if (root.animatingOut) {
            foreground.opacity = 0;
          }
        }
      }
    }
  }

  ShinyRectangle {
    anchors.fill: parent
    focus: true

    Keys.onPressed: kevent => {
      root.animatingOut = true;
    }
  }

  Timer {
    running: root.animatingIn
    interval: root.animateInDuration

    onTriggered: {
      root.animatingIn = false;
      root.ready = true;
    }
  }

  Timer {
    running: root.animatingOut
    interval: root.animateOutDuration

    onTriggered: {
      root.sessionLock.locked = false;
      console.info("Unlocked lock screen");
    }
  }

  // Start animation when component load
  Component.onCompleted: {
    root.animatingIn = true;
  }
}
