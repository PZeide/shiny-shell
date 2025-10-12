pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property int refreshInterval: 5 * 60 * 1000
  property int weatherRefreshInterval: 3 * 60 * 1000
}
