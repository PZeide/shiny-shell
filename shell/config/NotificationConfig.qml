pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.utils

JsonObject {
  property bool enablePopups: true
  property bool enableSound: true
  property real soundVolume: 0.5
  property string soundPath: Paths.assetPath("sounds/notification.wav")
  property int popupTimeout: 7000
}
