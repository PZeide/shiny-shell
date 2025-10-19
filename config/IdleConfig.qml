pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property list<var> items: [
    {
      timeout: 300,
      actions: ["setbrightness,0.3"]
    },
    {
      timeout: 500,
      actions: ["dpms"]
    },
    {
      timeout: 900,
      actions: ["suspend"]
    }
  ]

  /**
   * Possible actions:
   * - lock
   * - dpms
   * - setbrightness,{value%}
   * - suspend
   * - suspendhibernate
   * - execenter,{command}
   * - execleave,{command}
   */
  component IdleItem: JsonObject {
    required property int timeout
    property list<string> actions: []
  }
}
