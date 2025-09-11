pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property int refreshInterval: 15 * 60 * 1000
  property string provider: "auto"
  property int weatherRefreshInterval: 5 * 60 * 1000
  property string temperatureUnit: "celsius"
}
