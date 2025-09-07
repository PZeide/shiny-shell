pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pam
import qs.Widgets
import qs.Config

Item {
  id: root

  required property bool processing
  required property int error
  property alias lockHeight: lockIndicator.height
  property alias errorHeight: errorIndicator.height

  ShinyRectangle {
    id: errorIndicator

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: errorText.width + 24
    implicitHeight: errorText.height + 8
    color: Config.appearance.color.bgError
    bottomLeftRadius: Config.appearance.rounding.md
    bottomRightRadius: Config.appearance.rounding.md

    ShinyText {
      id: errorText

      clip: true
      wrapMode: Text.NoWrap
      anchors.centerIn: parent
    }
  }

  ShinyRectangle {
    id: lockIndicator

    anchors.top: errorIndicator.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: lockIcon.width + 24
    implicitHeight: lockIcon.height + 6
    color: Config.appearance.color.bgPrimary
    bottomLeftRadius: Config.appearance.rounding.md
    bottomRightRadius: Config.appearance.rounding.md

    Icon {
      id: lockIcon

      anchors.centerIn: parent
      icon: "lock"
      font.pointSize: Config.appearance.font.size.lg
      fill: root.processing
    }
  }

  onErrorChanged: {
    if (root.error !== PamResult.Success) {
      switch (root.error) {
      case PamResult.MaxTries:
        errorText.text = "Maximum login attempts reached.";
        break;
      case PamResult.Failed:
        errorText.text = "Login failed. Please try again.";
        break;
      case PamResult.Error:
        errorText.text = "An error occurred.";
        break;
      }
    }
  }
}
