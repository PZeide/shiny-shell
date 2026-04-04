pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt.labs.synchronizer
import qs.components
import qs.components.controls
import qs.config
import qs.utils.animations

ShinyRectangle {
  id: root

  required property var items
  required property int selectedIndex
  required property string input

  signal itemClicked(int index)

  implicitHeight: container.implicitHeight + container.anchors.topMargin + container.anchors.bottomMargin
  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

  ShinyRectangle {
    id: container
    anchors.centerIn: parent
    anchors.margins: Config.appearance.spacing.sm
    implicitWidth: parent.implicitWidth - anchors.leftMargin - anchors.rightMargin
    implicitHeight: itemsColumn.implicitHeight + searchField.implicitHeight
    clip: true

    Behavior on implicitHeight {
      EffectNumberAnimation {}
    }

    ShinyRectangle {
      id: selection
      visible: itemsRepeater.count > root.selectedIndex
      y: root.selectedIndex * (height + itemsColumn.spacing)
      implicitWidth: parent.implicitWidth
      implicitHeight: 70
      color: Config.appearance.color.secondaryContainer
      radius: Config.appearance.rounding.sm

      Behavior on y {
        ExpressiveNumberAnimation {
          duration: Config.appearance.anim.durations.sm
        }
      }
    }

    ColumnLayout {
      id: itemsColumn
      spacing: Config.appearance.spacing.md
      width: root.implicitWidth

      Repeater {
        id: itemsRepeater
        model: root.items

        LauncherItem {
          required property int index

          Layout.fillWidth: true
          implicitHeight: 70

          onItemClicked: root.itemClicked(index)
          onItemEntered: root.selectedIndex = index
        }
      }

      Item {
        visible: itemsRepeater.count > 0
        implicitWidth: parent.implicitWidth
        implicitHeight: Config.appearance.spacing.xs
      }
    }

    ShinyRectangle {
      anchors.fill: searchField
      color: Config.appearance.color.surface
    }

    ShinyTextField {
      id: searchField
      anchors.bottom: parent.bottom
      implicitWidth: parent.implicitWidth
      placeholderText: "Search..."
      sIcon.name: "search"
      focus: true

      Synchronizer on text {
        property alias source: root.input
      }
    }
  }
}
