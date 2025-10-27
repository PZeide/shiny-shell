pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

Scope {
  LockContext {
    id: context

    onLockedChanged: Session.locked = locked
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

  Connections {
    target: Session

    function onLockRequested() {
      context.lock();
    }

    function onUnlockRequested() {
      context.unlock();
    }
  }
}
