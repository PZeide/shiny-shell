pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property int timeout: 2000
  property bool audioSinkEnabled: true
  property bool audioSourceEnabled: true
  property bool brightnessEnabled: true
}
