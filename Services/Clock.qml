pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell

Singleton {
  readonly property alias date: sysClock.date

  SystemClock {
    id: sysClock
    precision: SystemClock.Seconds
  }
}
