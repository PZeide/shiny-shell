pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components
import qs.layers.bar
import qs.utils

BarModuleWrapper {
  ShinyIcon {
    icon: Weather.now.icon
    fill: 1
    color: Config.appearance.color.primary
  }

  ShinyText {
    text: Formatting.temperature(Weather.now.temperature)
    font.pointSize: Config.appearance.font.size.sm
  }
}
