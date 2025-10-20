pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property string timeFormat: "h:mm a"
  property string dateFullFormat: "dddd d MMMM"
  property string dateShortFormat: "ddd d MMM"
  property string temperatureUnit: "celsius"
}
