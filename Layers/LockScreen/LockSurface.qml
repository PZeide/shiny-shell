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

  readonly property int fadeInDuration: Config.appearance.anim.durations.lg
  readonly property int fadeOutDuration: Config.appearance.anim.durations.lg

  color: "transparent"

  function unlock() {
    console.info("Unlocking lock screen");
    handler.state = "fadeOut";
  }

  Item {
    id: handler

    states: [
      State {
        name: "fadeIn"
      },
      State {
        name: "idle"
      },
      State {
        name: "fadeOut"
      }
    ]

    transitions: [
      Transition {
        from: "*"
        to: "fadeIn"
        SequentialAnimation {
          PauseAnimation {
            duration: root.fadeInDuration
          }
          ScriptAction {
            script: handler.state = "idle"
          }
        }
      },
      Transition {
        from: "idle"
        to: "fadeOut"
        SequentialAnimation {
          PauseAnimation {
            duration: root.fadeOutDuration
          }
          ScriptAction {
            script: root.sessionLock.locked = false
          }
        }
      }
    ]
  }

  Loader {
    active: Config.wallpaper.enabled
    anchors.fill: parent

    sourceComponent: Background {
      id: background

      source: Config.wallpaper.path
      opacity: handler.state === "idle" || handler.state === "fadeIn" ? 1 : 0

      Behavior on opacity {
        NumberAnimation {
          duration: handler.state === "fadeIn" ? root.fadeInDuration : root.fadeOutDuration
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Config.appearance.anim.curves.standard
        }
      }

      layer.enabled: true
      layer.effect: MultiEffect {
        id: backgroundEffect

        blurEnabled: true

        NumberAnimation on blur {
          running: handler.state === "idle"
          duration: Config.appearance.anim.durations.lg
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Config.appearance.anim.curves.standard
          from: 0
          to: 0.8
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
      opacity: handler.state === "idle" || handler.state === "fadeIn" ? 1 : 0

      Behavior on opacity {
        NumberAnimation {
          duration: handler.state === "fadeIn" ? root.fadeInDuration : root.fadeOutDuration
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Config.appearance.anim.curves.standard
        }
      }
    }
  }

  ShinyRectangle {
    anchors.fill: parent
    focus: true

    Keys.onPressed: kevent => root.unlock()
  }

  // Start fadeIn when component is complete
  Component.onCompleted: {
    handler.state = "fadeIn";
  }
}
