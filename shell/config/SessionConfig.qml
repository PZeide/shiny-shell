pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.utils

JsonObject {
  property string username: "User"
  property string facePath: Paths.assetPath("images/face.png")
  property bool controlEnabled: true
  property string shutdownCommand: "systemctl poweroff"
  property string rebootCommand: "systemctl reboot"
  property string suspendCommand: "systemctl suspend"
  property bool lockOnSuspend: true

  /**
    * Possible actions:
    * - lock
    * - dpms (if dpms is enabled before locking, the lockscreen will be black)
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
      actions: ["suspend"]
    }
  ]
}
