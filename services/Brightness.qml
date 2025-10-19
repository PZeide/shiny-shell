pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Shiny.Services
import qs.config

Singleton {
  id: root

  readonly property bool isAvailable: Config.brightness.enabled && controller.available
  readonly property int smoothMaxDuration: 600
  readonly property alias linearValue: controller.value
  readonly property alias naturalValue: controller.naturalValue
  readonly property double userValue: Config.brightness.natural ? naturalValue : linearValue

  function set(target: real, smooth = undefined, natural = undefined) {
    if (smooth === undefined)
      smooth = Config.brightness.smooth;

    if (natural === undefined)
      natural = Config.brightness.natural;

    target = Math.min(Math.max(target, 0), 1);

    if (smooth) {
      if (natural) {
        const duration = Math.abs(target - root.naturalValue) * root.smoothMaxDuration;
        controller.setNaturalValueSmooth(target, duration);
      } else {
        const duration = Math.abs(target - root.linearValue) * root.smoothMaxDuration;
        controller.setValueSmooth(target, duration);
      }
    } else {
      if (natural) {
        controller.setNaturalValue(target);
      } else {
        controller.setValue(target);
      }
    }
  }

  BrightnessController {
    id: controller
    controller: Config.brightness.controller
  }

  IpcHandler {
    id: ipc

    target: "brightness"

    function get(): string {
      return JSON.stringify(root.isAvailable ? {
        available: true,
        linearValue: root.linearValue,
        naturalValue: root.naturalValue,
        userValue: root.userValue
      } : {
        available: false
      });
    }

    function set(command: string): string {
      if (!root.isAvailable)
        return "unavailable";

      command = command.trim();
      let target;

      const parseFloatStrict = str => {
        // Only digits and a single dot allowed
        const validFloatRegex = /^\d+(\.\d+)?$/;
        if (validFloatRegex.test(str)) {
          return parseFloat(str);
        }

        return NaN;
      };

      if (command.startsWith("+")) {
        if (command.endsWith("%")) {
          const value = parseFloatStrict(command.slice(1, -1));
          target = root.userValue + (value / 100);
        } else {
          const value = parseFloatStrict(command.slice(1));
          target = root.userValue + value;
        }
      } else if (command.endsWith("-")) {
        if (command.endsWith("%-")) {
          const value = parseFloatStrict(command.slice(0, -2));
          target = root.userValue - (value / 100);
        } else {
          const value = parseFloatStrict(command.slice(0, -1));
          target = root.userValue - value;
        }
      } else if (command.endsWith("%")) {
        const value = parseFloatStrict(command.slice(0, -1));
        target = value / 100;
      } else {
        const value = parseFloatStrict(command);
        target = value;
      }

      if (isNaN(target))
        return `invalid command: ${command} (excepted: 0.1, +0.1, 0.1-, 10%, +10%, 10%-)`;

      root.set(target);
      return "ok";
    }
  }
}
