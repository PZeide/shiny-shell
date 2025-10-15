pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.utils
import qs.config
import qs.widgets

Scope {
  WlSessionLock {
    id: sessionLock

    LockSurface {
      sessionLock: sessionLock
    }
  }

  IpcHandler {
    id: ipc

    target: "lockscreen"

    function lock() {
      sessionLock.locked = true;
    }

    function unlock() {
      sessionLock.locked = false;
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
      sessionLock.locked = true;
    }
  }
}
