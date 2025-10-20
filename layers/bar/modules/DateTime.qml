pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components
import qs.layers.bar

BarModuleWrapper {
  ShinyText {
    text: Qt.formatTime(Clock.date, Config.locale.timeFormat)
    font.pointSize: Config.appearance.font.size.md
  }

  ShinyText {
    text: "•"
    font.pointSize: Config.appearance.font.size.xl
  }

  ShinyText {
    text: Qt.formatDate(Clock.date, Config.locale.dateShortFormat)
    font.pointSize: Config.appearance.font.size.md
  }
}
