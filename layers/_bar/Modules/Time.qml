pragma ComponentBehavior: Bound

import QtQuick
import qs.Config
import qs.Widgets
import qs.Services

ShinyMouseArea {
  implicitWidth: timeText.contentWidth + 10
  implicitHeight: timeText.contentHeight

  Text {
    id: timeText

    anchors.centerIn: parent
    color: Config.appearance.color.fgPrimary
    font.pointSize: Config.appearance.font.size.md
    text: Qt.formatDateTime(Clock.date, "h:mm AP")
  }

  onPressed: {}
}
