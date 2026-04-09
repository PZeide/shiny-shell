pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services
import qs.components
import qs.components.controls
import qs.utils.animations

ShinyRectangle {
  id: root

  required property var availableMonitors
  readonly property int elementsPerRow: 3
  readonly property int elementWidth: Math.floor((width - layout.columnSpacing * 2 - view.leftPadding - view.rightPadding) / elementsPerRow)
  readonly property int elementHeight: 150

  signal selectedMonitor(HyprlandMonitor monitor)

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
        model: root.availableMonitors
        delegate: ShinyRectangle {
          id: element

          required property HyprlandMonitor modelData

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

            onClicked: root.selectedMonitor(element.modelData)
          }

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Config.appearance.padding.xs
            spacing: 0

            ShinyClippingRectangle {
              Layout.alignment: Qt.AlignCenter
              Layout.fillHeight: true
              Layout.bottomMargin: Config.appearance.padding.xs
              radius: Config.appearance.rounding.sm

              Layout.preferredWidth: {
                const transform = element.modelData.lastIpcObject.transform;
                const isPortrait = (transform === 1 || transform === 3 || transform === 5 || transform === 7);

                const effectiveWidth = isPortrait ? element.modelData.height : element.modelData.width;
                const effectiveHeight = isPortrait ? element.modelData.width : element.modelData.height;

                return Math.min(height * (effectiveWidth / effectiveHeight), parent.width);
              }

              ScreencopyView {
                anchors.fill: parent
                captureSource: HyprCompositor.toShellScreen(element.modelData)
                live: true
              }
            }

            ShinyText {
              Layout.fillWidth: true
              text: element.modelData.name
              font.pointSize: Config.appearance.font.size.sm
              font.weight: Font.Black
              wrapMode: Text.NoWrap
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignHCenter
            }

            ShinyText {
              Layout.fillWidth: true
              text: `${element.modelData.width}x${element.modelData.height} ${element.modelData.x}:${element.modelData.y}`
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
