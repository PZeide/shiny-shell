pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

QtObject {
  function transparentize(color: color, percentage: real): color {
    return Qt.rgba(color.r, color.g, color.b, color.a * (1 - percentage));
  }
}
