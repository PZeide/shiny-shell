pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components
import qs.components.controls
import qs.utils
import qs.utils.animations

ShinyRectangle {
  id: root

  required property var availableWindows
  readonly property int elementsPerRow: 3
  readonly property int elementWidth: Math.floor((width - layout.columnSpacing * 2 - view.leftPadding - view.rightPadding) / elementsPerRow)
  readonly property int elementHeight: 150

  signal selectedWindow(HyprlandToplevel monitor)

  color: Config.appearance.color.surfaceContainer

  ShinyScrollView {
    id: view
    anchors.fill: parent
    padding: Config.appearance.spacing.lg

    GridLayout {
      id: layout
      anchors.centerIn: parent
      columns: 3
      uniformCellWidths: true
      uniformCellHeights: true
      columnSpacing: Config.appearance.spacing.lg
      rowSpacing: Config.appearance.spacing.lg

      Repeater {
        model: root.availableWindows
        delegate: ShinyRectangle {
          id: element

          required property HyprlandToplevel modelData

          Layout.preferredWidth: root.elementWidth
          Layout.preferredHeight: root.elementHeight
          radius: Config.appearance.spacing.md
          border.color: area.containsPress ? Config.appearance.color.primary : Config.appearance.color.outline

          border.width: {
            if (area.containsPress) {
              return 2;
            } else if (area.containsMouse) {
              return 1;
            } else {
              return 0;
            }
          }

          color: {
            if (area.containsPress) {
              return Config.appearance.color.surfaceBright;
            } else if (area.containsMouse) {
              return Config.appearance.color.surfaceContainerHighest;
            } else {
              return Config.appearance.color.surfaceContainerHigh;
            }
          }

          Behavior on border.color {
            EffectColorAnimation {}
          }

          Behavior on border.width {
            EffectNumberAnimation {}
          }

          MouseArea {
            id: area
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: root.selectedWindow(element.modelData)
          }

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Config.appearance.padding.xs
            spacing: 0

            ShinyClippingRectangle {
              id: wrapper
              Layout.alignment: Qt.AlignCenter
              Layout.fillHeight: true
              Layout.bottomMargin: Config.appearance.padding.xs
              radius: Config.appearance.rounding.sm

              Layout.preferredWidth: {
                const effectiveWidth = element.modelData.lastIpcObject.size[0];
                const effectiveHeight = element.modelData.lastIpcObject.size[1];
                return Math.min(height * (effectiveWidth / effectiveHeight), parent.width);
              }

              ScreencopyView {
                anchors.fill: parent
                captureSource: element.modelData.wayland
                live: true
              }

              IconImage {
                anchors.centerIn: parent
                source: Icons.findFromClass(element.modelData.lastIpcObject.class)
                implicitSize: Math.min(wrapper.width, wrapper.height) * 0.4
              }
            }

            ShinyText {
              Layout.fillWidth: true
              text: element.modelData?.title
              font.pointSize: Config.appearance.font.size.sm
              font.weight: Font.Black
              wrapMode: Text.NoWrap
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignHCenter
            }

            ShinyText {
              Layout.fillWidth: true
              text: `${element.modelData?.lastIpcObject?.class}`
              font.pointSize: Config.appearance.font.size.xs
              wrapMode: Text.NoWrap
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignHCenter
            }
          }
        }
      }
    }
  }
}
