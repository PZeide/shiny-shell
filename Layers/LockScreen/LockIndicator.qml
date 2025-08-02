pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pam
import qs.Widgets
import qs.Config

ShinyRectangle {
  id: root

  required property PamContext pam
  required property int error
  required property bool unlocking
  property bool errorShown

  anchors.horizontalCenter: parent.horizontalCenter
  anchors.verticalCenter: parent.verticalCenter
  anchors.verticalCenterOffset: parent.height / 4
  width: contentLayout.implicitWidth
  height: contentLayout.implicitHeight
  color: root.errorShown ? Config.appearance.color.bgError : Config.appearance.color.bgPrimary
  radius: Config.appearance.rounding.lg

  Behavior on color {
    ColorAnimation {
      duration: Config.appearance.anim.durations.sm
    }
  }

  Behavior on width {
    NumberAnimation {
      duration: Config.appearance.anim.durations.sm
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Config.appearance.anim.curves.standard
    }
  }

  Item {
    id: contentLayout

    anchors.fill: parent
    implicitWidth: iconContainer.width + (errorLoader.active ? errorLoader.implicitWidth + 16 : 0)
    implicitHeight: 48

    Item {
      id: iconContainer

      anchors.left: parent.left
      implicitWidth: 48
      implicitHeight: 48

      Icon {
        id: icon

        icon: "lock"
        font.pointSize: 16
        fill: root.pam.active || root.unlocking
        anchors.centerIn: parent
      }
    }

    Loader {
      id: errorLoader

      active: root.error !== PamResult.Success && root.errorShown
      anchors.left: iconContainer.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.rightMargin: 16

      sourceComponent: ShinyText {
        clip: true
        wrapMode: Text.NoWrap
        text: {
          if (root.error === PamResult.MaxTries) {
            return "Maximum login attempts reached.";
          } else if (root.error === PamResult.Failed) {
            return "Login failed. Please try again.";
          } else if (root.error === PamResult.Error) {
            return "An error occurred.";
          }
        }
      }
    }
  }

  Timer {
    id: hideError

    interval: 5000
    onTriggered: root.errorShown = false
  }

  onErrorChanged: {
    if (error !== PamResult.Success) {
      root.errorShown = true;
      hideError.restart();
    }
  }
}
