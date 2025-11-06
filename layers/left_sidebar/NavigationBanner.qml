pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.utils.animations

ShinyRectangle {
  id: root

  required property list<var> elements
  property int selectedIndex: 0
  property Item selectedItem: null

  implicitHeight: selectionIndicator.implicitHeight + elementsLayout.implicitHeight

  GridLayout {
    id: elementsLayout
    anchors.left: parent.left
    anchors.right: parent.right
    columns: root.elements.length
    columnSpacing: 0
    uniformCellWidths: true
    uniformCellHeights: true

    Repeater {
      id: elementsRepeater
      model: root.elements

      delegate: ShinyRectangle {
        id: element

        required property int index
        required property string id
        required property string name
        required property string icon
        readonly property bool selected: root.selectedIndex === index

        implicitWidth: layout.implicitWidth + 20
        implicitHeight: layout.implicitHeight + 12
        Layout.alignment: Qt.AlignCenter

        onSelectedChanged: {
          if (selected)
            root.selectedItem = this;
        }

        ShinyInteractiveLayer {
          id: mouseArea
          anchors.fill: parent
          acceptedButtons: element.selected ? Qt.NoButton : Qt.LeftButton
          hoverEnabled: !element.selected

          onPressed: root.selectedIndex = element.index
        }

        ColumnLayout {
          id: layout
          anchors.centerIn: parent

          ShinyIcon {
            icon: element.icon
            font.pointSize: Config.appearance.font.size.xl
            color: element.selected ? Config.appearance.color.primary : Config.appearance.color.overSurface
            Layout.alignment: Qt.AlignHCenter
          }

          ShinyText {
            text: element.name
            color: element.selected ? Config.appearance.color.primary : Config.appearance.color.overSurface
            Layout.alignment: Qt.AlignHCenter
          }
        }
      }
    }
  }

  ShinyRectangle {
    id: selectionIndicator

    visible: root.selectedItem !== null
    anchors.top: elementsLayout.bottom
    x: root.selectedItem?.x ?? 0
    implicitWidth: root.selectedItem?.implicitWidth ?? 0
    implicitHeight: 4
    color: Config.appearance.color.primary
    radius: Config.appearance.rounding.sm

    Behavior on x {
      ExpressiveNumberAnimation {}
    }

    Behavior on implicitWidth {
      ExpressiveFastNumberAnimation {}
    }
  }
}
