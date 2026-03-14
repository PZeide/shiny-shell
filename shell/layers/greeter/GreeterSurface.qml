pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt.labs.synchronizer
import qs.layers.wallpaper
import qs.utils.animations
import qs.config
import qs.components.containers
import qs.layers.greeter.components as GreeterComponents

Item {
  id: root
  anchors.fill: parent

  required property GreeterContext context
  property bool visuallyShown: false

  component GreeterNumberAnimation: EffectNumberAnimation {
    duration: Config.appearance.anim.durations.lg
  }

  WallpaperImage {
    id: wallpaper
    anchors.fill: parent
    imageWidth: parent.width
    imageHeight: parent.height

    layer.enabled: true
    layer.effect: MultiEffect {
      autoPaddingEnabled: false
      blurEnabled: true
      blur: root.visuallyShown ? 1 : 0
      blurMax: 32
      blurMultiplier: 1
      contrast: root.visuallyShown ? 0.05 : 0
      saturation: root.visuallyShown ? 0.1 : 0

      Behavior on blur {
        GreeterNumberAnimation {}
      }

      Behavior on contrast {
        GreeterNumberAnimation {}
      }

      Behavior on saturation {
        GreeterNumberAnimation {}
      }
    }
  }

  GreeterComponents.Clock {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: Config.appearance.spacing.xxl
    scale: root.visuallyShown ? 1 : 0.9
    opacity: root.visuallyShown ? 1 : 0

    Behavior on scale {
      GreeterNumberAnimation {}
    }

    Behavior on opacity {
      GreeterNumberAnimation {}
    }
  }

  ShinyElevatedContainer {
    target: loginError
    opacity: root.visuallyShown ? 1 : 0

    Behavior on opacity {
      GreeterNumberAnimation {}
    }
  }

  GreeterComponents.LoginError {
    id: loginError
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: login.bottom
    anchors.topMargin: root.context.error !== "" ? Config.appearance.spacing.md : -height
    scale: root.visuallyShown ? 1 : 0.9
    opacity: root.visuallyShown ? 1 : 0
    error: root.context.error

    Behavior on anchors.topMargin {
      ExpressiveFastNumberAnimation {}
    }

    Behavior on scale {
      GreeterNumberAnimation {}
    }

    Behavior on opacity {
      GreeterNumberAnimation {}
    }
  }

  ShinyElevatedContainer {
    target: login
    opacity: root.visuallyShown ? 1 : 0

    Behavior on opacity {
      GreeterNumberAnimation {}
    }
  }

  GreeterComponents.Login {
    id: login
    anchors.centerIn: parent
    scale: root.visuallyShown ? 1 : 0.9
    opacity: root.visuallyShown ? 1 : 0
    acceptAuthentication: root.context.acceptAuthentication
    session: root.context.sessionEntry

    onAuthenticationRequested: root.context.requestAuthentication()

    Behavior on scale {
      GreeterNumberAnimation {}
    }

    Behavior on opacity {
      GreeterNumberAnimation {}
    }

    Synchronizer on password {
      sourceObject: root.context
      sourceProperty: "password"
    }
  }

  Component.onCompleted: {
    root.visuallyShown = true;
    login.focusField();
  }
}
