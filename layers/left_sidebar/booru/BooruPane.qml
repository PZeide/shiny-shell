pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

ColumnLayout {
  spacing: 0

  ShinyRectangle {
    color: "red"
    Layout.fillWidth: true
    Layout.fillHeight: true
  }

  ShinyRectangle {
    color: Config.appearance.color.bgSecondary
    Layout.fillWidth: true
    implicitHeight: 3
  }

  ColumnLayout {
    Layout.fillWidth: true
    Layout.topMargin: 4

    ShinyTextArea {
      id: textArea
      Layout.fillWidth: true
      placeholderText: "Search tags..."
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: false

      ShinySwitch {
        text: "Allow NSFW"
      }
    }
  }
}
