pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property list<string> devicesBlacklist: []
  property bool smooth: true
}
