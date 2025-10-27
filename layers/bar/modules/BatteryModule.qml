pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components
import qs.layers.bar

BarModuleWrapper {
  id: root

  readonly property bool batteryCaution: Battery.isLow && !Battery.isPluggedIn

  ShinyRectangle {
    id: batteryRectangle
    implicitWidth: 30
    implicitHeight: root.height * 0.5
    color: root.batteryCaution ? Config.appearance.color.errorContainer : Config.appearance.color.primaryContainer
    radius: Config.appearance.rounding.xs

    ShinyIcon {
      id: chargingIconAnchor
      anchors.centerIn: parent
      visible: Battery.isPluggedIn
      icon: "bolt"
      font.pointSize: Config.appearance.font.size.xs
      color: root.batteryCaution ? Config.appearance.color.overErrorContainer : Config.appearance.color.overPrimaryContainer
      fill: 1
    }

    ShinyClippingRectangle {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      implicitWidth: batteryRectangle.implicitWidth * Battery.percentage
      color: root.batteryCaution ? Config.appearance.color.error : Config.appearance.color.primary
      topLeftRadius: Config.appearance.rounding.xs
      bottomLeftRadius: Config.appearance.rounding.xs
      topRightRadius: Config.appearance.rounding.xxs
      bottomRightRadius: Config.appearance.rounding.xxs

      ShinyIcon {
        x: chargingIconAnchor.x
        y: chargingIconAnchor.y
        visible: Battery.isPluggedIn
        icon: "bolt"
        font.pointSize: Config.appearance.font.size.xs
        color: root.batteryCaution ? Config.appearance.color.overError : Config.appearance.color.overPrimary
        fill: 1
      }
    }
  }

  ShinyText {
    text: Battery.formattedPercentage
    font.pointSize: Config.appearance.font.size.sm
    color: root.batteryCaution ? Config.appearance.color.error : Config.appearance.color.overSurface
  }
}
