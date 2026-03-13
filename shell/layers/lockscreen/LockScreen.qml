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
    locked: context.presented

    LockSurface {
      id: surface
      context: context
    }
  }
}
