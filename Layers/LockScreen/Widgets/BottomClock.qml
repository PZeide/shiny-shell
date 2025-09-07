pragma ComponentBehavior: Bound

import QtQuick
import qs.Widgets
import qs.Config
import qs.Services

ShinyRectangle {
  id: root

  readonly property int timeSize: 72
  readonly property int dateSize: 18
  // Arbitrary dates but whatever
  readonly property var targetTimeMetrics: new Date(0, 0, 0, 23, 59, 59)
  readonly property var targetDateMetrics: new Date(2000, 8, 27)

  implicitWidth: Math.max(timeMetrics.width, dateMetrics.width) + 48
  implicitHeight: contentColumn.height + 32
  color: Config.appearance.color.bgPrimary
  topRightRadius: Config.appearance.rounding.lg

  TextMetrics {
    id: timeMetrics

    text: Qt.formatTime(root.targetTimeMetrics, Config.locale.timeFormat)
    renderType: Text.NativeRendering
    font.family: Config.appearance.font.family.sans
    font.pointSize: root.timeSize
    font.weight: Font.Black
  }

  TextMetrics {
    id: dateMetrics

    text: Qt.formatDate(root.targetDateMetrics, Config.locale.dateFullFormat)
    renderType: Text.NativeRendering
    font.family: Config.appearance.font.family.sans
    font.pointSize: root.dateSize
    font.weight: Font.Light
  }

  Column {
    id: contentColumn

    anchors.centerIn: parent

    ShinyText {
      text: Qt.formatTime(Clock.date, Config.locale.timeFormat)
      font.pointSize: root.timeSize
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      font.weight: Font.Black
    }

    ShinyText {
      text: Qt.formatDate(Clock.date, Config.locale.dateFullFormat)
      font.pointSize: root.dateSize
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
      font.weight: Font.Light
    }
  }
}
