pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Utils
import qs.Config

Scope {
  WlSessionLock {
    id: sessionLock

    LockSurface {
      sessionLock: sessionLock
    }
  }

  IpcHandler {
    target: "lockscreen"

    function lock() {
      console.info("Received lock request from IPC");
      sessionLock.locked = true;
    }

    function unlock() {
      console.info("Received unlock request from IPC");
      sessionLock.locked = false;
    }
  }

  Component.onCompleted: {
    if (!Env.isDev && Config.lockScreen.lockOnStart) {
      console.info("Auto-lock on start!");
      sessionLock.locked = true;
    }
  }
}
