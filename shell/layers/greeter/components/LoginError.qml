pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.config

ShinyRectangle {
  id: root

  required property string error

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
      if (root.error == "") {
        // If error has been cleared, we keep the original error for the animation
        return text;
      }

      return root.error;
    }
  }
}
