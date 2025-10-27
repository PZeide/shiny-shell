pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.config
import qs.services
import qs.layers.corner

ShinyRectangle {
  id: root

  readonly property int timeSize: Config.appearance.font.size.huge
  readonly property int dateSize: Config.appearance.font.size.xl
  readonly property var targetTimeMetrics: new Date(0, 0, 0, 23, 59, 59)
  readonly property var targetDateMetrics: new Date(2000, 8, 27)

  implicitWidth: Math.max(timeMetrics.width, dateMetrics.width) + Config.appearance.padding.xl * 2
  implicitHeight: contentColumn.height + Config.appearance.padding.lg * 2
  color: Config.appearance.color.surface
  topRightRadius: Config.appearance.rounding.lg

  TextMetrics {
    id: timeMetrics
    text: Qt.formatTime(root.targetTimeMetrics, Config.locale.timeFormat).replace(/ (AM|PM|am|pm)/, "")
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
      text: Qt.formatTime(Clock.date, Config.locale.timeFormat).replace(/ (AM|PM|am|pm)/, "")
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

  RoundedCorner {
    anchors.bottom: parent.top
    anchors.left: parent.left
    type: RoundedCorner.Type.BottomLeft
  }
}
