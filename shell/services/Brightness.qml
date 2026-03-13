pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Shiny.Brightness
import qs.config
import qs.utils

Singleton {
  id: root

  readonly property bool isAvailable: Config.brightness.enabled
  readonly property list<BrightnessDevice> devices: controllers.instances.filter(device => device.available)

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

  function forDefaultDevice(): BrightnessDevice {
    if (devices.length === 0)
      return null;

    if (devices.length === 1)
      return devices[0];

    const focused = Hyprland.focusedMonitor?.name ?? null;
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

  function forDevice(name: string): BrightnessDevice {
    return devices.find(controller => controller.device === name);
  }

  IpcHandler {
    id: ipc
    target: "brightness"

    function list(): string {
      return Helpers.success(root.devices.map(root.formatController));
    }

    function get(device: string): string {
      const controller = device === "%default%" ? root.forDefaultDevice() : root.forDevice(device);
      if (controller !== null) {
        return Helpers.success(root.formatController(controller));
      } else {
        return Helpers.fail("Failed to find device");
      }
    }

    function set(device: string, command: string): string {
      const controller = device === "%default%" ? root.forDefaultDevice() : root.forDevice(device);
      if (controller === null) {
        return Helpers.fail("Failed to find device");
      }

      const currentBrightness = controller.brightness;
      let targetBrightness;

      const parseFloatStrict = str => {
        // Only digits and a single dot allowed
        const validFloatRegex = /^\d+(\.\d+)?$/;
        if (validFloatRegex.test(str)) {
          return parseFloat(str);
        }

        return NaN;
      };

      command = command.trim();
      if (command.startsWith("+")) {
        if (command.endsWith("%")) {
          const value = parseFloatStrict(command.slice(1, -1));
          targetBrightness = currentBrightness + (value / 100);
        } else {
          const value = parseFloatStrict(command.slice(1));
          targetBrightness = currentBrightness + value;
        }
      } else if (command.endsWith("-")) {
        if (command.endsWith("%-")) {
          const value = parseFloatStrict(command.slice(0, -2));
          targetBrightness = currentBrightness - (value / 100);
        } else {
          const value = parseFloatStrict(command.slice(0, -1));
          targetBrightness = currentBrightness - value;
        }
      } else if (command.endsWith("%")) {
        const value = parseFloatStrict(command.slice(0, -1));
        targetBrightness = value / 100;
      } else {
        const value = parseFloatStrict(command);
        targetBrightness = value;
      }

      if (isNaN(targetBrightness)) {
        return Helpers.fail(`Invalid command: ${command} (i.e: 0.1, +0.1, 0.1-, 10%, +10%, 10%-)`);
      }

      root.setDeviceBrightness(controller, targetBrightness);
      return Helpers.success({
        device: controller.device,
        target: targetBrightness,
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
