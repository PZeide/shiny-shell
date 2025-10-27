pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services
import qs.utils
import qs.utils.animations
import qs.layers.corner
import qs.layers.bar
import qs.layers.bar.modules

ShinyRectangle {
  id: root
  implicitHeight: Config.bar.height
  color: Config.appearance.color.surface

  // Used to position pill centered horizontally
  required property real leftOffset
  required property real rightOffset

  RoundedCorner {
    anchors.bottom: parent.top
    anchors.left: parent.left
    type: RoundedCorner.Type.BottomLeft
  }

  RoundedCorner {
    anchors.bottom: parent.top
    anchors.right: parent.right
    type: RoundedCorner.Type.BottomRight
  }

  RowLayout {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    spacing: Config.appearance.spacing.sm

    Loader {
      Layout.fillHeight: true
      active: Location.isAvailable
      sourceComponent: LocationModule {}
    }

    Loader {
      Layout.fillHeight: true
      active: Weather.isAvailable
      sourceComponent: WeatherModule {}
    }
  }

  BarModuleWrapper {
    x: (root.width + root.leftOffset + root.rightOffset) / 2 - width / 2 - root.leftOffset

    ShinyText {
      text: "Enter your password to unlock"
    }
  }

  RowLayout {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    spacing: Config.appearance.spacing.sm

    Loader {
      Layout.fillHeight: true
      active: Battery.isAvailable
      sourceComponent: BatteryModule {}
    }
  }
}
