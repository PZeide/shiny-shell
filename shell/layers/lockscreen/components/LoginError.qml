pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pam
import qs.components
import qs.config

ShinyRectangle {
  id: root

  required property int pamResult

  implicitWidth: errorText.implicitWidth + Config.appearance.padding.lg * 2
  implicitHeight: errorText.implicitHeight + Config.appearance.padding.sm * 2
  color: Config.appearance.color.errorContainer
  radius: Config.appearance.rounding.xs

  ShinyText {
    id: errorText
    anchors.centerIn: parent
    clip: true
    wrapMode: Text.NoWrap
    color: Config.appearance.color.overErrorContainer

    text: {
      switch (root.pamResult) {
      case PamResult.MaxTries:
        return "Maximum login attempts reached.";
      case PamResult.Failed:
        return "Login failed. Please try again.";
      case PamResult.Error:
        return "An error occurred.";
      default:
        // If the error is not one of the predefined cases, return the current text
        return text;
      }
    }
  }
}
