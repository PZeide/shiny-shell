pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

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
}
