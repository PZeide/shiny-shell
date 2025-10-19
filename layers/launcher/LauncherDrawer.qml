pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.config
import qs.utils.animations

ShinyRectangle {
  id: root

  required property var items
  property int selectedIndex: 0
  property string input: ""

  signal itemClicked(int index)
  signal itemEntered(int index)

  width: parent.width
  implicitHeight: itemsContainer.implicitHeight + searchField.implicitHeight + container.anchors.margins * 2
  color: Config.appearance.color.bgPrimary
  radius: Config.appearance.rounding.md

  ShinyRectangle {
    id: container
    anchors.fill: parent
    anchors.margins: 8
    clip: true

    ShinyRectangle {
      id: selection
      visible: itemsRepeater.count > root.selectedIndex
      y: root.selectedIndex * (height + itemsColumn.spacing)
      width: parent.width
      height: 70
      color: Config.appearance.color.bgSecondary
      radius: Config.appearance.rounding.lg

      Behavior on y {
        ExpressiveFastNumberAnimation {}
      }
    }

    Item {
      id: itemsContainer
      width: parent.width
      implicitHeight: itemsColumn.implicitHeight

      Behavior on implicitHeight {
        EffectNumberAnimation {}
      }

      Column {
        id: itemsColumn
        spacing: 6
        width: parent.width

        Repeater {
          id: itemsRepeater
          model: root.items

          LauncherItem {
            required property int index

            onItemClicked: root.itemClicked(index)
            onItemEntered: root.itemEntered(index)
          }
        }

        Item {
          visible: itemsRepeater.count > 0
          width: parent.width
          height: 4
        }
      }
    }

    ShinyTextField {
      id: searchField
      anchors.bottom: parent.bottom
      width: parent.width
      placeholderText: "Search..."
      icon: "search"
      focus: true
      radius: Config.appearance.rounding.md

      onTextChanged: root.input = text
    }
  }
}
