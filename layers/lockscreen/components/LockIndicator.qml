pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pam
import qs.components
import qs.config
import qs.layers.corner

Item {
  id: root

  required property bool processing
  required property int error

  property alias lockHeight: lockIndicator.implicitHeight
  property alias errorHeight: errorIndicator.implicitHeight

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

  ShinyRectangle {
    id: errorIndicator
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: errorText.implicitWidth + Config.appearance.padding.lg * 2
    implicitHeight: errorText.implicitHeight + Config.appearance.padding.xs * 2
    color: Config.appearance.color.errorContainer
    bottomLeftRadius: Config.appearance.rounding.md
    bottomRightRadius: Config.appearance.rounding.md

    ShinyText {
      id: errorText
      clip: true
      wrapMode: Text.NoWrap
      anchors.centerIn: parent
      color: Config.appearance.color.overErrorContainer
    }
  }

  RoundedCorner {
    anchors.top: errorIndicator.top
    anchors.left: errorIndicator.right
    type: RoundedCorner.Type.TopLeft
    implicitSize: Config.appearance.rounding.corner * 0.7
    color: Config.appearance.color.errorContainer
  }

  RoundedCorner {
    anchors.top: errorIndicator.top
    anchors.right: errorIndicator.left
    type: RoundedCorner.Type.TopRight
    implicitSize: Config.appearance.rounding.corner * 0.7
    color: Config.appearance.color.errorContainer
  }

  ShinyRectangle {
    id: lockIndicator
    anchors.top: errorIndicator.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: lockIcon.implicitWidth + Config.appearance.padding.lg * 2
    implicitHeight: lockIcon.implicitHeight + Config.appearance.padding.xs * 2
    color: root.processing ? Config.appearance.color.primaryContainer : Config.appearance.color.surface
    bottomLeftRadius: Config.appearance.rounding.md
    bottomRightRadius: Config.appearance.rounding.md

    ShinyIcon {
      id: lockIcon
      anchors.centerIn: parent
      icon: "lock"
      font.pointSize: Config.appearance.font.size.lg
      color: root.processing ? Config.appearance.color.overPrimaryContainer : Config.appearance.color.overSurface
    }
  }

  RoundedCorner {
    anchors.top: errorIndicator.bottom
    anchors.left: lockIndicator.right
    type: RoundedCorner.Type.TopLeft
    implicitSize: Config.appearance.rounding.corner * 0.7
    color: root.processing ? Config.appearance.color.primaryContainer : Config.appearance.color.surface
  }

  RoundedCorner {
    anchors.top: errorIndicator.bottom
    anchors.right: lockIndicator.left
    type: RoundedCorner.Type.TopRight
    implicitSize: Config.appearance.rounding.corner * 0.7
    color: root.processing ? Config.appearance.color.primaryContainer : Config.appearance.color.surface
  }
}
