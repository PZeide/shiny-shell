pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Shiny.DBus
import qs.config
import qs.components.containers
import qs.components.misc
import qs.services

Singleton {
  id: root

  readonly property var idleCache: ({})
  property bool locked: false

  signal lockRequested
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

  function lock() {
    if (Config.session.lockCommand) {
      Quickshell.execDetached(["sh", "-c", Config.session.lockCommand.trim()]);
    } else {
      console.info("Requesting shiny-shell lock");
      lockRequested();
    }
  }

  function unlock() {
    if (Config.session.unlockCommand) {
      Quickshell.execDetached(["sh", "-c", Config.session.unlockCommand.trim()]);
    } else {
      console.info("Requesting shiny-shell unlock");
      unlockRequested();
    }
  }

  function handleIdleAction(action: string, rid: string) {
    let args = action.split(",");
    const command = args[0]?.trim() ?? "";
    args = args.slice(1);

    switch (command) {
    case "lock":
      root.lock();
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

      idleCache[rid] = Brightness.userValue;
      Brightness.set(value);
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

  function handleWakeupAction(action: string, rid: string) {
    let args = action.split(",");
    const command = args[0]?.trim() ?? "";
    args = args.slice(1);

    switch (command) {
    case "dpms":
      Hyprland.dispatch("dpms on");
      break;
    case "setbrightness":
      const prevValue = idleCache[rid];
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

  Variants {
    model: Config.session.idleItems

    IdleMonitor {
      required property var modelData

      readonly property string rid: Math.random().toString(36).substring(2, 15)

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

  IdleInhibitor {
    id: inhibitor
    enabled: false
    window: ShinyWindow {
      name: "inhibitor"
      implicitWidth: 0
      implicitHeight: 0
    }
  }

  LogindHandler {
    sleepInhibited: true
    sleepInhibitDescription: "Session management"
    lockHint: root.locked

    onLockRequested: {
      console.info("Received lock request from Logind");
      root.lock();
    }

    onUnlockRequested: {
      console.info("Received unlock request from Logind");
      root.unlock();
    }

    onAboutToSleep: {
      if (Config.session.lockOnSuspend)
        root.lock();

      sleepInhibited = false;
    }

    onResumedFromSleep: {
      // Flash inhibitor to wake up everything
      inhibitor.enabled = true;
      inhibitor.enabled = false;
      sleepInhibited = true;
    }
  }

  IpcHandler {
    target: "session"

    function shutdown(): string {
      root.shutdown();
      return "ok";
    }

    function reboot(): string {
      root.reboot();
      return "ok";
    }

    function suspend(): string {
      root.suspend();
      return "ok";
    }

    function lock(): string {
      root.lock();
      return "ok";
    }

    function unlock(): string {
      root.unlock();
      return "ok";
    }
  }

  ShinyShortcut {
    name: "session-shutdown"
    description: "Request a session shutdown"
    onPressed: root.shutdown()
  }

  ShinyShortcut {
    name: "session-reboot"
    description: "Request a session reboot"
    onPressed: root.reboot()
  }

  ShinyShortcut {
    name: "session-suspend"
    description: "Request a session suspend"
    onPressed: root.suspend()
  }

  ShinyShortcut {
    name: "session-lock"
    description: "Request a session lock"
    onPressed: root.lock()
  }

  ShinyShortcut {
    name: "session-unlock"
    description: "Request a session unlock"
    onPressed: root.unlock()
  }
}
