pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.services
import qs.widgets
import qs.utils
import qs.layers.wallpaper
import qs.layers.corner
import qs.layers.lockscreen.widgets

WlSessionLockSurface {
  id: root

  required property WlSessionLock sessionLock
  readonly property bool unlocking: handler.state === "animateOut" || handler.state === "fadeOut"
  readonly property int errorDuration: 5000
  property int error: PamResult.Success
  property real opacityFactor: 0
  property real readinessFactor: 0

  color: "transparent"

  function unlock() {
    console.info("Unlocking lock screen");
    handler.state = "animateOut";
  }

  Item {
    id: handler

    states: [
      State {
        name: "fadeIn"
      },
      State {
        name: "animateIn"
      },
      State {
        name: "idle"
      },
      State {
        name: "animateOut"
      },
      State {
        name: "fadeOut"
      }
    ]

    transitions: [
      Transition {
        to: "fadeIn"
        SequentialAnimation {
          NumberAnimation {
            target: root
            property: "opacityFactor"
            to: 1
            duration: Animations.expressive.duration
            easing.type: Animations.expressive.type
            easing.bezierCurve: Animations.expressive.curve
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
          NumberAnimation {
            target: root
            property: "readinessFactor"
            to: 1
            duration: Animations.moveEnterSlow.duration
            easing.type: Animations.moveEnterSlow.type
            easing.bezierCurve: Animations.moveEnterSlow.curve
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
          NumberAnimation {
            target: root
            property: "readinessFactor"
            to: 0
            duration: Animations.moveExitSlow.duration
            easing.type: Animations.moveExitSlow.type
            easing.bezierCurve: Animations.moveExitSlow.curve
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
          NumberAnimation {
            target: root
            property: "opacityFactor"
            to: 0
            duration: Animations.expressive.duration
            easing.type: Animations.expressive.type
            easing.bezierCurve: Animations.expressive.curve
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
      opacity: root.opacityFactor
      layer.effect: MultiEffect {
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 0.65 * root.readinessFactor
        blurMax: 48
      }
    }
  }

  Barcode {
    anchors.centerIn: parent
    passwordBuffer: input.text
    opacity: Math.max(0, 2 * root.opacityFactor - 1)
  }

  Loader {
    active: Config.wallpaper.enabled && Config.wallpaper.foreground && Foreground.isAvailable
    anchors.fill: parent

    sourceComponent: WallpaperImage {
      id: foreground

      source: Foreground.path
      opacity: root.opacityFactor
    }
  }

  ShinyRectangle {
    id: bottomRectangle

    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottomMargin: -bottomRectangle.height * (1 - root.readinessFactor)
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

    RoundedCorner {
      anchors.bottom: bottomClock.top
      anchors.left: parent.left
      type: RoundedCorner.Type.BottomLeft
    }

    RoundedCorner {
      anchors.bottom: bottomMusic.top
      anchors.right: parent.right
      type: RoundedCorner.Type.BottomRight
    }

    RoundedCorner {
      anchors.bottom: bottomBar.top
      anchors.left: bottomClock.right
      type: RoundedCorner.Type.BottomLeft
    }

    RoundedCorner {
      anchors.bottom: bottomBar.top
      anchors.right: bottomMusic.left
      type: RoundedCorner.Type.BottomRight
    }
  }

  LockIndicator {
    id: lockIndicator

    property real errorTopMargin: root.error === PamResult.Success ? -errorHeight : 0

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: errorTopMargin - lockHeight * (1 - root.readinessFactor)
    processing: root.unlocking || pam.active
    error: root.error

    Behavior on errorTopMargin {
      animation: Animations.effects.createNumber(this)
    }
  }

  RoundedCorner {
    anchors.top: parent.top
    anchors.left: parent.left
    type: RoundedCorner.Type.TopLeft
  }

  RoundedCorner {
    anchors.top: parent.top
    anchors.right: parent.right
    type: RoundedCorner.Type.TopRight
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
