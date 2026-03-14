pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.utils

ColumnLayout {
  ShinyText {
    text: Formatting.time(false)
    font.pointSize: Config.appearance.font.size.huge
    Layout.alignment: Qt.AlignHCenter
    font.weight: Font.Black
  }

  ShinyText {
    text: Formatting.dateFull()
    font.pointSize: Config.appearance.font.size.xl
    Layout.alignment: Qt.AlignHCenter
  }
}
