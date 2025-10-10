pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
  readonly property bool isAvailable: UPower.displayDevice.ready && UPower.displayDevice.isLaptopBattery
  readonly property int state: UPower.displayDevice.state
  readonly property real percentage: UPower.displayDevice.percentage
  readonly property string formattedPercentage: `${(UPower.displayDevice.percentage * 100).toFixed(1)}%`
  readonly property bool isLow: percentage <= 0.2 && state !== UPowerDeviceState.Charging

  readonly property string icon: {
    const isCharging = state === UPowerDeviceState.Charging;
    const percentage = UPower.displayDevice.percentage;

    if (percentage <= 0.05 && !isCharging) {
      return "battery_0_bar";
    } else if (percentage <= 0.2) {
      return isCharging ? "battery_charging_20" : "battery_1_bar";
    } else if (percentage <= 0.3) {
      return isCharging ? "battery_charging_30" : "battery_2_bar";
    } else if (percentage <= 0.5) {
      return isCharging ? "battery_charging_50" : "battery_3_bar";
    } else if (percentage <= 0.6) {
      return isCharging ? "battery_charging_60" : "battery_4_bar";
    } else if (percentage <= 0.8) {
      return isCharging ? "battery_charging_80" : "battery_5_bar";
    } else if (percentage <= 0.9) {
      return isCharging ? "battery_charging_90" : "battery_6_bar";
    } else {
      return isCharging ? "battery_charging_full" : "battery_full";
    }
  }

  readonly property string timeToEmpty: UPower.displayDevice.timeToEmpty
  readonly property string timeToFull: UPower.displayDevice.timeToFull
  readonly property bool isHealthSupported: UPower.displayDevice.healthSupported
  readonly property real healthPercentage: UPower.displayDevice.healthPercentage
}
