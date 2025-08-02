pragma Singleton

import Quickshell

Singleton {
  property alias date: sysClock.date

  SystemClock {
    id: sysClock
    precision: SystemClock.Seconds
  }
}
