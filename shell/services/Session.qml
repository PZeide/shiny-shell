pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Shiny.Session
import qs.services
import qs.utils
import qs.config
import qs.components.containers

Singleton {
  id: root

  property var idleCache: ({})
  property bool locked: SessionManager.lockedHint

  signal lockRequested(bool requestNotification)
  signal unlockRequested

  function shutdown() {
    Quickshell.execDetached(["sh", "-c", Config.session.shutdownCommand.trim()]);
  }

  function reboot() {
    Quickshell.execDetached(["sh", "-c", Config.session.rebootCommand.trim()]);
  }

  function suspend() {
    Quickshell.execDetached(["sh", "-c", Config.session.suspendCommand.trim()]);
  }

  function lock(requestNotification = false) {
    if (Config.lockScreen.enabled) {
      root.lockRequested(requestNotification);
    } else {
      console.info("Lock screen is disabled");
    }
  }

  function unlock() {
    if (Config.lockScreen.enabled) {
      root.unlockRequested();
    } else {
      console.info("Lock screen is disabled");
    }
  }

  function notifyLockReady() {
    if (inhibitorLock.active) {
      console.info("Lock screen is ready, releasing inhibitor lock");
      inhibitorLock.release();
    }
  }

  function handleIdleAction(action: string, key: string) {
    let args = action.split(",");
    const command = args[0]?.trim() ?? "";
    args = args.slice(1);

    switch (command) {
    case "lock":
      root.lock();
      break;
    case "dpms":
      HyprCompositor.dispatch("dpms off");
      break;
    case "setbrightness":
      if (args.length < 1) {
        console.warn("Idle action setbrightness is missing value argument");
        return;
      }

      const value = parseFloat(args[0]);
      if (value == NaN || value < 0 || value > 1) {
        console.warn(`Idle action setbrightness has an invalid value: ${value}`);
        return;
      }

      for (const controller of Brightness.devices) {
        idleCache[`${key}-${controller.device}`] = controller.brightness;
        Brightness.setDeviceBrightness(controller, value);
      }

      break;
    case "suspend":
      root.suspend();
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

  function handleWakeupAction(action: string, key: string) {
    let args = action.split(",");
    const command = args[0]?.trim() ?? "";
    args = args.slice(1);

    switch (command) {
    case "dpms":
      HyprCompositor.dispatch("dpms on");
      break;
    case "setbrightness":
      for (const controller of Brightness.devices) {
        const prevValue = idleCache[`${key}-${controller.device}`];
        if (prevValue === undefined) {
          console.warn("Missing old brightness value in cache, something went wrong...");
          return;
        }

        Brightness.setDeviceBrightness(controller, prevValue);
      }
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

  Variants {
    model: Config.session.idleItems

    IdleMonitor {
      required property var modelData
      readonly property string key: Math.random().toString(36).substring(2, 15)

      enabled: true
      timeout: modelData.timeout ?? Infinity
      respectInhibitors: true

      onIsIdleChanged: {
        if (isIdle) {
          console.info(`Reached idle item at ${timeout}s`);
          modelData.actions?.forEach(a => root.handleIdleAction(a, key));
        } else {
          modelData.actions?.forEach(a => root.handleWakeupAction(a, key));
          root.idleCache = {};
        }
      }
    }
  }

  IdleInhibitor {
    id: inhibitor
    enabled: false
    window: ShinyWindow {
      name: "inhibitor"
      implicitWidth: 0
      implicitHeight: 0
    }
  }

  Connections {
    target: SessionManager

    function onLockRequested() {
      console.info("Received lock request from login1");
      root.lockRequested(false);
    }

    function onUnlockRequested() {
      console.info("Received lock request from login1");
      root.unlockRequested();
    }
  }

  InhibitorLock {
    id: inhibitorLock
    description: "Session management"
    type: InhibitorLock.Sleep

    onActionRequired: {
      if (Config.session.lockOnSuspend) {
        root.lock(true);

        // If we do not use the lock screen module, release inhibitor lock immediately since we cannot know when the lock screen is ready
        // If we do use the lock screen module, the inhibitor lock will be released when the lock screen has finished animating (Through Session.notifyLockReady())
        if (!Config.lockScreen.enabled) {
          release();
        }
      } else {
        release();
      }
    }

    onActiveChanged: {
      if (!active) {
        // When system is back from suspend, we can turn on the inhibtor to make sure that system is not idling anymore
        inhibitor.enabled = true;
        inhibitor.enabled = false;
      }
    }
  }

  IpcHandler {
    id: ipc
    target: "session"

    function shutdown(): string {
      root.shutdown();
      return Helpers.success("ok");
    }

    function reboot(): string {
      root.reboot();
      return Helpers.success("ok");
    }

    function suspend(): string {
      root.suspend();
      return Helpers.success("ok");
    }

    function lock(): string {
      root.lock();
      return Helpers.success("ok");
    }
  }
}
