pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.components
import qs.components.controls
import qs.utils
import qs.layers.lockscreen.components as LockComponents

Loader {
  active: Battery.isAvailable
  width: (item as Item)?.implicitWidth || 0
  height: parent.height

  sourceComponent: LockComponents.SystemModuleWrapper {
    id: root

    readonly property bool batteryCaution: Battery.isLow && !Battery.isPluggedIn
    readonly property string tooltipText: {
      switch (Battery.state) {
      case UPowerDeviceState.FullyCharged:
        return "Fully charged";
      case UPowerDeviceState.Charging:
      case UPowerDeviceState.PendingDischarge:
        return Battery.timeToFull > 0 ? `${Formatting.prettyDuration(Battery.timeToFull)} until charged` : "Calculating time until charged...";
      case UPowerDeviceState.PendingCharge:
        return "Charging on hold";
      case UPowerDeviceState.Discharging:
        return Battery.timeToEmpty > 0 ? `${Formatting.prettyDuration(Battery.timeToEmpty)} left` : "Calculating time left...";
      default:
        return "";
      }
    }

    ShinyInteractiveLayer {
      id: layer
      anchors.fill: parent
      layerRadius: Config.appearance.rounding.xs
      acceptedButtons: Qt.NoButton
      hoverEnabled: root.tooltipText !== ""
    }

    ShinyTooltip {
      visible: layer.containsMouse && root.tooltipText !== ""
      text: root.tooltipText
    }

    contentItem: RowLayout {
      id: layout
      implicitHeight: parent.implicitHeight

      ShinyRectangle {
        id: batteryRectangle
        implicitWidth: 35
        implicitHeight: layout.implicitHeight * 0.8
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
  }
}
