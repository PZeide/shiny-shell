pragma ComponentBehavior: Bound

import QtQuick
import qs.config

NumberAnimation {
  duration: Config.appearance.anim.durations.md
  easing.type: Easing.InSine
}
