pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.widgets
import qs.config

ShinyRectangle {
  id: root

  required property bool isSystemIcon
  required property string icon
  required property string name
  required property string description

  signal itemClicked
  signal itemEntered

  radius: Config.appearance.rounding.xs
  width: parent.width
  height: 70

  MouseArea {
    id: mouseArea

    anchors.fill: parent
    hoverEnabled: true

    onPressed: root.itemClicked()
    onEntered: root.itemEntered()
  }

  RowLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    anchors.verticalCenter: parent.verticalCenter
    spacing: 8

    ShinyClippingRectangle {
      id: itemIcon

      property int iconSize: root.height - 24

      implicitWidth: iconSize
      implicitHeight: iconSize
      radius: Config.appearance.rounding.sm

      Image {
        anchors.fill: parent
        visible: root.isSystemIcon
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        retainWhileLoading: true
        sourceSize.width: itemIcon.iconSize
        sourceSize.height: itemIcon.iconSize
        source: Quickshell.iconPath(root.icon, true)
      }

      ShinyIcon {
        anchors.fill: parent
        visible: !root.isSystemIcon
        icon: root.icon
        font.pointSize: Config.appearance.font.size.xxl
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 0

      ShinyText {
        Layout.fillWidth: true
        Layout.alignment: root.description === "" ? Qt.AlignVCenter : Qt.AlignTop
        text: root.name
        font.pointSize: Config.appearance.font.size.md
        font.weight: Font.Medium
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
      }

      ShinyText {
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? implicitHeight : 0
        visible: root.description !== ""
        text: root.description
        font.pointSize: Config.appearance.font.size.sm
        font.weight: Font.Light
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
      }
    }
  }
}
