pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import Shiny.Helpers
import qs.config
import qs.components
import qs.utils

T.TabButton {
  id: root

  property icon sIcon: Helpers.emptyIcon()
  property alias sIconFont: icon.font
  readonly property bool hasIcon: sIcon.name !== ""
  readonly property color textColor: {
    if (!root.enabled) {
      return Config.appearance.color.outline;
    } else if (root.checked) {
      return Config.appearance.color.overSurface;
    } else if (root.hovered) {
      return Config.appearance.color.outline;
    } else {
      return Config.appearance.color.overSurfaceVariant;
    }
  }

  implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
  implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
  padding: Config.appearance.padding.xxs
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.sm
  font.weight: Font.Medium
  spacing: Config.appearance.padding.sm

  contentItem: Item {
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
      id: layout
      anchors.centerIn: parent
      spacing: root.spacing

      ShinyIcon {
        id: icon
        Layout.alignment: Qt.AlignVCenter
        visible: root.hasIcon
        icon: root.sIcon.name
        fill: root.sIcon.fill
        grade: root.sIcon.grade
        color: root.textColor
        font.pointSize: Config.appearance.font.size.lg
      }

      ShinyText {
        id: text
        Layout.alignment: Qt.AlignVCenter
        visible: root.text !== ""
        text: root.text
        font: root.font
        color: root.textColor
      }
    }
  }
}
