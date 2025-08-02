pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.Config
import qs.Services

WlSessionLockSurface {
  id: root

  required property WlSessionLock sessionLock
  readonly property int fadeDuration: Config.appearance.anim.durations.lg
  readonly property real animatedOpacity: handler.state === "idle" || handler.state === "fadeIn" ? 1 : 0
  property int error: PamResult.Success

  color: "transparent"

  function unlock() {
    console.info("Unlocking lock screen");
    handler.state = "fadeOut";
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
            duration: root.fadeDuration
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

    sourceComponent: Image {
      id: background

      anchors.fill: parent
      antialiasing: true
      cache: true
      mipmap: true
      retainWhileLoading: true
      fillMode: Image.PreserveAspectCrop
      horizontalAlignment: Config.wallpaper.horizontalAlignement
      verticalAlignment: Config.wallpaper.verticalAlignement
      source: Config.wallpaper.path
      opacity: root.animatedOpacity

      layer.enabled: true
      layer.effect: MultiEffect {
        id: backgroundEffect

        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: 48

        NumberAnimation on blur {
          running: handler.state === "idle"
          duration: Config.appearance.anim.durations.lg
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Config.appearance.anim.curves.standard
          from: 0
          to: 0.65
        }
      }

      Behavior on opacity {
        FadeFullAnimation {}
      }
    }
  }

  Barcode {
    passwordBuffer: input.text
    opacity: root.animatedOpacity

    Behavior on opacity {
      FadeFastAnimation {}
    }
  }

  Loader {
    active: Config.wallpaper.enabled && Config.wallpaper.foreground && Foreground.canShow
    anchors.fill: parent

    sourceComponent: Image {
      id: foreground

      anchors.fill: parent
      antialiasing: true
      cache: true
      mipmap: true
      retainWhileLoading: true
      fillMode: Image.PreserveAspectCrop
      horizontalAlignment: Config.wallpaper.horizontalAlignement
      verticalAlignment: Config.wallpaper.verticalAlignement
      source: Foreground.path
      opacity: root.animatedOpacity

      Behavior on opacity {
        FadeFullAnimation {}
      }
    }
  }

  LockIndicator {
    id: indicator

    pam: pam
    error: root.error
    unlocking: handler.state === "fadeOut"
    opacity: root.animatedOpacity

    Behavior on opacity {
      FadeFullAnimation {}
    }
  }

  GhostPasswordInput {
    id: input

    readOnly: pam.active
    onAccepted: {
      if (pam.active) {
        return;
      }

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
        // We want to reset the status first so that it re-triggers a change
        if (root.error === result) {
          root.error = PamResult.Success;
        }

        root.error = result;
        input.clear();
      }
    }

    onResponseRequiredChanged: {
      if (!responseRequired)
        return;

      respond(input.text);
    }
  }

  // Start fadeIn when component is complete
  Component.onCompleted: {
    handler.state = "fadeIn";
  }
}
