pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import Shiny.Brightness
import qs.services
import qs.config
import qs.utils

Singleton {
  id: root

  readonly property bool isAvailable: Config.brightness.enabled
  readonly property list<BrightnessDevice> devices: controllers.instances.filter(device => device.available)
  readonly property BrightnessDevice defaultDevice: {
    if (devices.length === 0)
      return null;

    if (devices.length === 1)
      return devices[0];

    const focused = HyprCompositor.activeMonitor?.name ?? null;
    let edpFallback = null;

    for (const controller of devices) {
      if (focused !== null && controller.device === focused) {
        return controller;
      }

      if (edpFallback === null && controller.device.startsWith("eDP")) {
        edpFallback = controller;
      }
    }

    return edpFallback;
  }

  Variants {
    id: controllers
    model: Quickshell.screens.filter(device => !Config.brightness.devicesBlacklist.includes(device.name))

    BrightnessDevice {
      property ShellScreen modelData

      device: modelData.name
    }
  }

  function setDeviceBrightness(device: BrightnessDevice, value: double) {
    const safeValue = Math.min(Math.max(value, 0), 1);
    if (Config.brightness.smooth) {
      device.commitBrightnessSmooth(safeValue);
    } else {
      device.commitBrightness(safeValue);
    }
  }

  function forDevice(name: string): BrightnessDevice {
    return devices.find(controller => controller.device === name);
  }

  IpcHandler {
    id: ipc
    enabled: root.isAvailable
    target: "brightness"

    function list(): string {
      return Helpers.success(root.devices.map(root.formatController));
    }

    function get(device: string): string {
      const controller = device === "%default%" ? root.defaultDevice : root.forDevice(device);
      if (controller !== null) {
        return Helpers.success(root.formatController(controller));
      } else {
        return Helpers.fail("failed to find device");
      }
    }

    function set(device: string, command: string): string {
      const controller = device === "%default%" ? root.defaultDevice : root.forDevice(device);
      if (controller === null) {
        return Helpers.fail("failed to find device");
      }

      const result = Helpers.parseDecimalCommand(command.trim(), controller.brightness);
      if (isNaN(result)) {
        return Helpers.fail(`invalid brightness: ${command} (i.e: 0.1, +0.1, -0.1, 10%, +10%, -10%)`);
      }

      const clampedBrightness = Math.min(Math.max(result, 0), 1);
      root.setDeviceBrightness(controller, clampedBrightness);
      return Helpers.success({
        device: controller.device,
        target: clampedBrightness,
        smooth: Config.brightness.smooth
      });
    }
  }

  function formatController(controller: BrightnessDevice): var {
    return {
      device: controller.device,
      brightness: controller.brightness,
      effectiveBrightness: controller.realBrightness
    };
  }
}
