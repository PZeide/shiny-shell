pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property string shutdownCommand: "systemctl poweroff"
  property string rebootCommand: "systemctl reboot"
  property string suspendCommand: "systemctl suspend"
  property string lockCommand: ""
  property string unlockCommand: ""

  property bool lockOnSuspend: true

  /**
    * Possible actions:
    * - lock
    * - dpms
    * - setbrightness,{value%}
    * - suspend
    * - execenter,{command}
    * - execleave,{command}
    */
  property list<var> idleItems: [
    {
      timeout: 300,
      actions: ["setbrightness,0.3"]
    },
    {
      timeout: 600,
      actions: ["dpms"]
    },
    {
      timeout: 900,
      actions: ["suspend"]
    }
  ]
}
