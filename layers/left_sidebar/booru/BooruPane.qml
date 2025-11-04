pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.controls
import qs.config

ColumnLayout {
  spacing: 0

  ShinyRectangle {
    color: "red"
    Layout.fillWidth: true
    Layout.fillHeight: true
  }

  ShinyRectangle {
    color: Config.appearance.color.surfaceBright
    Layout.fillWidth: true
    implicitHeight: 2
  }

  ColumnLayout {
    Layout.fillWidth: true
    Layout.topMargin: 4
    spacing: Config.appearance.spacing.sm

    ShinyTextArea {
      id: textArea
      Layout.fillWidth: true
      placeholderText: "Search tags..."
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.leftMargin: Config.appearance.spacing.xs
      Layout.rightMargin: Config.appearance.spacing.xs

      ShinyText {
        text: "Allow NSFW"
        color: allowNsfwSwitch.checked ? Config.appearance.color.overSurface : Config.appearance.color.outline
        font.pointSize: Config.appearance.font.size.sm
      }

      ShinySwitch {
        id: allowNsfwSwitch
      }

      Item {
        Layout.fillWidth: true
      }

      ShinyMenu {
        id: providerMenu
      }
    }
  }
}
