pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  function transparentize(color: color, percentage: real): color {
    return Qt.rgba(color.r, color.g, color.b, color.a * (1 - percentage));
  }

  function mix(a: color, b: color, percentage = 0.5) {
    return Qt.rgba(percentage * a.r + (1 - percentage) * b.r, percentage * a.g + (1 - percentage) * b.g, percentage * a.b + (1 - percentage) * b.b, percentage * a.a + (1 - percentage) * b.a);
  }
}
