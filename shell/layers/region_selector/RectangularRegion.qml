pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

QtObject {
  required property string source
  required property ShellScreen screen
  required property int x
  required property int y
  required property int width
  required property int height

  function contains(targetX, targetY) {
    return targetX >= x && targetX <= x + width && targetY >= y && targetY <= y + height;
  }
}
