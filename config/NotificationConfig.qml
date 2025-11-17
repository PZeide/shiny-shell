pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.utils

JsonObject {
  property bool enablePopups: true
  property bool enableSound: true
  property string urgentSound: Paths.assetPath("sounds/notification_urgent.ogg")
  property string normalSound: Paths.assetPath("sounds/notification_normal.ogg")
  property int popupTimeout: 7000
}
