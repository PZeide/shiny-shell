pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.Config
import qs.Services
import qs.Widgets
import qs.Layers.Wallpaper
import qs.Layers.LockScreen.Widgets

WlSessionLockSurface {
  id: root

  required property WlSessionLock sessionLock
  readonly property int fadeDuration: Config.appearance.anim.durations.lg
  readonly property int animateDuration: Config.appearance.anim.durations.lg
  readonly property bool unlocking: handler.state === "animateOut" || handler.state === "fadeOut"
  readonly property int errorDuration: 5000
  property int error: PamResult.Success
  property real opacity: 0
  property bool ready: false

  color: "transparent"

  function unlock() {
    console.info("Unlocking lock screen");
    handler.state = "animateOut";
  }

  component FadeFullAnimation: NumberAnimation {
    duration: root.fadeDuration
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Config.appearance.anim.curves.standard
  }

  component FadeFastAnimation: NumberAnimation {
    duration: root.fadeDuration / 2
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Config.appearance.anim.curves.standard
  }

  component ReadyAnimation: NumberAnimation {
    duration: root.animateDuration
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Config.appearance.anim.curves.standard
  }

  component ScreenCorner: Loader {
    id: loader

    required property int type

    active: Config.corner.enabled

    sourceComponent: RoundCorner {
      type: loader.type
      implicitSize: Config.corner.size
    }
  }

  Item {
    id: handler

    states: [
      State {
        name: "fadeIn"
        PropertyChanges {
          restoreEntryValues: false
          target: root
          opacity: 1
        }
      },
      State {
        name: "animateIn"
        PropertyChanges {
          restoreEntryValues: false
          target: root
          ready: true
        }
      },
      State {
        name: "idle"
      },
      State {
        name: "animateOut"
        PropertyChanges {
          restoreEntryValues: false
          target: root
          ready: false
        }
      },
      State {
        name: "fadeOut"
        PropertyChanges {
          restoreEntryValues: false
          target: root
          opacity: 0
        }
      }
    ]

    transitions: [
      Transition {
        to: "fadeIn"
        SequentialAnimation {
          PauseAnimation {
            duration: root.fadeDuration
          }
          ScriptAction {
            script: handler.state = "animateIn"
          }
        }
      },
      Transition {
        from: "fadeIn"
        to: "animateIn"
        SequentialAnimation {
          PauseAnimation {
            duration: root.animateDuration
          }
          ScriptAction {
            script: handler.state = "idle"
          }
        }
      },
      Transition {
        from: "idle"
        to: "animateOut"
        SequentialAnimation {
          PauseAnimation {
            duration: root.animateDuration
          }
          ScriptAction {
            script: handler.state = "fadeOut"
          }
        }
      },
      Transition {
        from: "animateOut"
        to: "fadeOut"
        SequentialAnimation {
          PauseAnimation {
            duration: root.fadeDuration
          }
          ScriptAction {
            script: root.sessionLock.locked = false
          }
        }
      }
    ]
  }

  MouseArea {
    anchors.fill: parent
    enabled: false
    cursorShape: Qt.BlankCursor
  }

  Loader {
    active: Config.wallpaper.enabled
    anchors.fill: parent

    sourceComponent: WallpaperImage {
      id: background

      source: Config.wallpaper.path
      opacity: root.opacity
      layer.effect: MultiEffect {
        autoPaddingEnabled: false
        blurEnabled: true
        blur: root.ready ? 0.65 : 0
        blurMax: 48

        Behavior on blur {
          ReadyAnimation {}
        }
      }

      Behavior on opacity {
        FadeFullAnimation {}
      }
    }
  }

  Barcode {
    anchors.centerIn: parent
    passwordBuffer: input.text
    opacity: root.opacity

    Behavior on opacity {
      FadeFastAnimation {}
    }
  }

  Loader {
    active: Config.wallpaper.enabled && Config.wallpaper.foreground && Foreground.isAvailable
    anchors.fill: parent

    sourceComponent: WallpaperImage {
      id: foreground

      source: Foreground.path
      opacity: root.opacity

      Behavior on opacity {
        FadeFullAnimation {}
      }
    }
  }

  ShinyRectangle {
    id: bottomRectangle

    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottomMargin: root.ready ? 0 : -(bottomRectangle.height)
    implicitHeight: Math.max(bottomBar.height, bottomClock.height, bottomMusic.height)

    BottomBar {
      id: bottomBar

      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      leftOffset: bottomClock.width
      rightOffset: bottomMusic.width
    }

    BottomClock {
      id: bottomClock

      anchors.bottom: parent.bottom
      anchors.left: parent.left
    }

    BottomMusic {
      id: bottomMusic

      anchors.bottom: parent.bottom
      anchors.right: parent.right
    }

    ScreenCorner {
      anchors.bottom: bottomClock.top
      anchors.left: parent.left
      type: RoundCorner.Type.BottomLeft
    }

    ScreenCorner {
      anchors.bottom: bottomMusic.top
      anchors.right: parent.right
      type: RoundCorner.Type.BottomRight
    }

    ScreenCorner {
      anchors.bottom: bottomBar.top
      anchors.left: bottomClock.right
      type: RoundCorner.Type.BottomLeft
    }

    ScreenCorner {
      anchors.bottom: bottomBar.top
      anchors.right: bottomMusic.left
      type: RoundCorner.Type.BottomRight
    }

    Behavior on anchors.bottomMargin {
      NumberAnimation {
        duration: root.animateDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Config.appearance.anim.curves.standard
      }
    }
  }

  LockIndicator {
    id: lockIndicator

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: {
      if (!root.ready) {
        return -(lockHeight + errorHeight);
      }

      return root.error === PamResult.Success ? -errorHeight : 0;
    }

    processing: root.unlocking || pam.active
    error: root.error

    Behavior on anchors.topMargin {
      ReadyAnimation {}
    }
  }

  ScreenCorner {
    anchors.top: parent.top
    anchors.left: parent.left
    type: RoundCorner.Type.TopLeft
  }

  ScreenCorner {
    anchors.top: parent.top
    anchors.right: parent.right
    type: RoundCorner.Type.TopRight
  }

  GhostPasswordInput {
    id: input

    readOnly: pam.active || root.unlocking
    onAccepted: {
      if (pam.active)
        return;

      pam.start();
    }
  }

  PamContext {
    id: pam

    onCompleted: result => {
      if (result === PamResult.Success) {
        root.error = PamResult.Success;
        root.unlock();
      } else {
        root.error = result;
        resetError.restart();
        input.clear();
      }
    }

    onResponseRequiredChanged: {
      if (!responseRequired)
        return;

      respond(input.text);
    }
  }

  Timer {
    id: resetError

    interval: root.errorDuration
    onTriggered: root.error = PamResult.Success
  }

  // Start fadeIn when component is complete
  Component.onCompleted: {
    handler.state = "fadeIn";
  }
}
