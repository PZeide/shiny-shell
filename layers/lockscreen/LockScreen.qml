pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Shiny.DBus
import qs.utils
import qs.config
import qs.components

Scope {
  LockContext {
    id: context
  }

  WlSessionLock {
    id: sessionLock

    locked: context.locked

    LockSurface {
      id: surface
      sessionLock: sessionLock
      context: context
    }
  }

  LogindHandler {
    sleepInhibited: true
    sleepInhibitDescription: "Lock the screen before sleep"
    lockHint: context.locked

    onLockRequested: {
      console.info("Received lock request from Logind");
      context.lock();
    }

    onUnlockRequested: {
      console.info("Received unlock request from Logind");
      context.unlock();
    }

    onAboutToSleep: {
      if (Config.lockScreen.lockOnSuspend)
        context.lock();

      sleepInhibited = false;
    }

    onResumedFromSleep: sleepInhibited = true
  }

  IpcHandler {
    id: ipc
    target: "lockscreen"

    function lock() {
      context.lock();
    }

    function unlock() {
      context.unlock();
    }
  }

  ShinyShortcut {
    name: "lockscreen-lock"
    description: "Lock session"
    onPressed: ipc.lock()
  }

  ShinyShortcut {
    name: "lockscreen-unlock"
    description: "Unlock session"
    onPressed: ipc.unlock()
  }

  Component.onCompleted: {
    if (Config.lockScreen.lockOnStart && !Environment.isDev) {
      console.info("Locking on start");
      context.lock();
    }
  }
}
