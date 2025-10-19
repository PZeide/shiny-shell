pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services

Scope {
  id: root

  readonly property var actionCache: ({})

  function handleIdleAction(action: string, rid: string) {
    let args = action.split(",");
    const command = args[0]?.trim() ?? "";
    args = args.slice(1);

    switch (command) {
    case "lock":
      Quickshell.execDetached(["loginctl", "lock-session"]);
      break;
    case "dpms":
      Hyprland.dispatch("dpms off");
      break;
    case "setbrightness":
      if (!Brightness.isAvailable) {
        console.warn("Idle action setbrightness cannot proceed because brightness isn't available");
        return;
      }

      if (args.length < 1) {
        console.warn("Idle action setbrightness is missing value argument");
        return;
      }

      const value = parseFloat(args[0]);
      if (value == NaN) {
        console.warn(`Idle action setbrightness has an invalid value: ${value}`);
        return;
      }

      actionCache[rid] = Brightness.userValue;
      Brightness.set(value);
      break;
    case "suspend":
      Quickshell.execDetached(["systemctl", "suspend"]);
      break;
    case "suspendhibernate":
      Quickshell.execDetached(["systemctl", "suspend-then-ibernate"]);
      break;
    case "execenter":
      if (args.length < 1) {
        console.warn("Idle action execenter is missing command argument");
        return;
      }

      Quickshell.execDetached(["sh", "-c", args[0].trim()]);
      break;
    }
  }

  function handleWakeupAction(action: string, rid: string) {
    let args = action.split(",");
    const command = args[0]?.trim() ?? "";
    args = args.slice(1);

    switch (command) {
    case "dpms":
      Hyprland.dispatch("dpms on");
      break;
    case "setbrightness":
      const prevValue = actionCache[rid];
      if (prevValue === undefined) {
        console.warn("Missing old brightness value in cache, something went wrong...");
        return;
      }

      Brightness.set(prevValue);
      break;
    case "execleave":
      if (args.length < 1) {
        console.warn("IdleItem execleave action is missing command argument");
        return;
      }

      Quickshell.execDetached(["sh", "-c", args[0].trim()]);
      break;
    }
  }

  function generateId(): string {
    return Math.random().toString(36).substring(2, 15);
  }

  Variants {
    model: Config.idle.items

    IdleMonitor {
      required property var modelData

      readonly property string rid: root.generateId()

      enabled: true
      timeout: modelData.timeout ?? Infinity
      respectInhibitors: true

      onIsIdleChanged: {
        if (isIdle) {
          console.info(`Reached idle item at ${timeout}s`);
          modelData.actions?.forEach(a => root.handleIdleAction(a, rid));
        } else {
          modelData.actions?.forEach(a => root.handleWakeupAction(a, rid));
        }
      }
    }
  }
}
