pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.utils.animations
import qs.components
import qs.components.containers
import qs.services
import qs.layers.lockscreen.components as LockComponents

WlSessionLockSurface {
  id: root

  required property LockContext context
  property bool visuallyLocked: false

  color: "transparent"

  component LockNumberAnimation: EffectNumberAnimation {
    duration: root.context.animationDuration
  }

  component LockColorAnimation: EffectColorAnimation {
    duration: root.context.animationDuration
  }

  ScreencopyView {
    anchors.fill: parent
    captureSource: root.screen
    live: false

    scale: root.visuallyLocked ? 1.1 : 1
    rotation: root.visuallyLocked ? 2 : 0

    Behavior on scale {
      LockNumberAnimation {}
    }

    Behavior on rotation {
      LockNumberAnimation {}
    }

    layer.enabled: true
    layer.effect: MultiEffect {
      autoPaddingEnabled: false
      blurEnabled: true
      blur: root.visuallyLocked ? 1 : 0
      blurMax: 32
      blurMultiplier: 1
      contrast: root.visuallyLocked ? 0.05 : 0
      saturation: root.visuallyLocked ? 0.1 : 0

      Behavior on blur {
        LockNumberAnimation {}
      }

      Behavior on contrast {
        LockNumberAnimation {}
      }

      Behavior on saturation {
        LockNumberAnimation {}
      }
    }

    ShinyRectangle {
      anchors.fill: parent
      color: Config.appearance.color.scrim
      opacity: root.visuallyLocked ? 0.2 : 0

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }
  }

  Item {
    id: elementsContainer

    readonly property int elementHeight: 80

    anchors.fill: parent

    LockComponents.Clock {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      scale: root.visuallyLocked ? 1 : 0.9
      opacity: root.visuallyLocked ? 1 : 0

      Behavior on scale {
        LockNumberAnimation {}
      }

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }

    ShinyElevatedContainer {
      target: loginError
      opacity: root.visuallyLocked ? 1 : 0

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }

    LockComponents.LoginError {
      id: loginError
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: login.top
      anchors.bottomMargin: root.context.result !== PamResult.Success ? Config.appearance.spacing.md : -height
      scale: 0
      opacity: 0
      pamResult: root.context.result

      Behavior on anchors.bottomMargin {
        ExpressiveFastNumberAnimation {}
      }

      Behavior on scale {
        LockNumberAnimation {}
      }

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }

    ShinyElevatedContainer {
      target: login
      opacity: root.visuallyLocked ? 1 : 0

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }

    LockComponents.Login {
      id: login
      anchors.bottom: parent.bottom
      anchors.bottomMargin: root.visuallyLocked ? Config.appearance.spacing.xl : -height
      anchors.horizontalCenter: parent.horizontalCenter
      implicitHeight: elementsContainer.elementHeight
      scale: root.visuallyLocked ? 1 : 0.9
      opacity: root.visuallyLocked ? 1 : 0
      fieldEnabled: !root.context.authenticating && root.context.locked

      Connections {
        target: root.context

        function onResultChanged() {
          if (root.context.result !== PamResult.Success) {
            login.reset();
          }
        }
      }

      Behavior on anchors.bottomMargin {
        LockNumberAnimation {}
      }

      Behavior on scale {
        LockNumberAnimation {}
      }

      Behavior on opacity {
        LockNumberAnimation {
          onRunningChanged: {
            if (running) {
              loginError.scale = 0;
              loginError.opacity = 0;
            } else {
              loginError.scale = 1;
              loginError.opacity = 1;
            }
          }
        }
      }

      onLoginRequested: password => root.context.tryAuthenticate(password)
    }

    ShinyElevatedContainer {
      target: music
      opacity: root.visuallyLocked && music.hasTrack ? 1 : 0

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }

    LockComponents.Music {
      id: music
      anchors.bottom: parent.bottom
      anchors.bottomMargin: root.visuallyLocked && music.hasTrack ? Config.appearance.spacing.xl : -height
      anchors.right: login.left
      anchors.rightMargin: Config.appearance.spacing.xxl * 3
      implicitHeight: elementsContainer.elementHeight
      scale: root.visuallyLocked && music.hasTrack ? 1 : 0.9
      opacity: root.visuallyLocked && music.hasTrack ? 1 : 0
      player: Player.preferred

      Behavior on anchors.bottomMargin {
        LockNumberAnimation {}
      }

      Behavior on scale {
        LockNumberAnimation {}
      }

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }

    ShinyElevatedContainer {
      target: system
      opacity: root.visuallyLocked ? 1 : 0

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }

    LockComponents.System {
      id: system
      anchors.bottom: parent.bottom
      anchors.bottomMargin: root.visuallyLocked ? Config.appearance.spacing.xl : -height
      anchors.left: login.right
      anchors.leftMargin: Config.appearance.spacing.xxl * 3
      implicitHeight: elementsContainer.elementHeight
      scale: root.visuallyLocked ? 1 : 0.9
      opacity: root.visuallyLocked ? 1 : 0

      Behavior on anchors.bottomMargin {
        LockNumberAnimation {}
      }

      Behavior on scale {
        LockNumberAnimation {}
      }

      Behavior on opacity {
        LockNumberAnimation {}
      }
    }
  }

  Connections {
    target: root.context

    function onLockedChanged() {
      if (!root.context.locked) {
        root.visuallyLocked = false;
      }
    }
  }

  Component.onCompleted: {
    root.visuallyLocked = true;
    login.focusField();
  }
}
