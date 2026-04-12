pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.synchronizer
import Quickshell
import qs.utils
import qs.config
import qs.components
import qs.components.controls
import qs.layers.region_selector

Item {
  id: root

  required property var availableMonitors
  required property var availableWindows
  required property bool allowCustomRegion
  property bool allowRestoreToken: false

  signal selectedMonitor(monitor: string)
  signal selectedWindow(windowAddress: string, stableId: string)
  signal selectedCustomRegion(region: RectangularRegion)
  signal cancelled

  // Dialog wrapped in an Item because Repeater requires an Item and FloatingWindow is not
  FloatingWindow {
    id: window

    readonly property size windowSize: Qt.size(700, 500)

    implicitWidth: windowSize.width
    implicitHeight: windowSize.height
    minimumSize: windowSize
    maximumSize: windowSize
    color: Config.appearance.color.surface

    onClosed: root.cancelled()

    ColumnLayout {
      id: layout
      anchors.fill: parent
      anchors.topMargin: Config.appearance.spacing.md
      anchors.bottomMargin: Config.appearance.spacing.md
      spacing: Config.appearance.spacing.lg

      ShinyTabBar {
        id: tabBar

        readonly property int firstAvailableIndex: {
          for (let i = 0; i < tabBar.count; i++) {
            if (tabBar.itemAt(i).enabled)
              return i;
          }

          return 0;
        }

        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        currentIndex: firstAvailableIndex

        Binding on currentIndex {
          value: tabBar.firstAvailableIndex
          when: !tabBar.itemAt(tabBar.currentIndex).enabled
        }

        ShinyTabButton {
          enabled: root.availableMonitors.values.length > 0
          text: "Monitor"
          sIcon.name: "computer"
        }

        ShinyTabButton {
          enabled: root.availableWindows.values.length > 0
          text: "Window"
          sIcon.name: "select_window"
        }

        ShinyTabButton {
          enabled: root.allowCustomRegion
          text: "Custom"
          sIcon.name: "activity_zone"

          onPressed: {
            let oldIndex = tabBar.currentIndex;
            window.visible = false;

            RegionSelection.request(selection => {
              if (selection === null) {
                console.info("Selection cancelled, restoring old index");
                window.visible = true;
                tabBar.currentIndex = oldIndex;
                return;
              }

              root.selectedCustomRegion(selection);
            }, {
              freeze: false,
              hintWindows: false,
              hintLayers: false
            });
          }
        }
      }

      SwipeView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex
        interactive: false

        PickerMonitor {
          availableMonitors: root.availableMonitors

          onSelectedMonitor: monitor => root.selectedMonitor(monitor.name)
        }

        PickerWindow {
          availableWindows: root.availableWindows

          onSelectedWindow: window => root.selectedWindow(window.address, window.lastIpcObject.stableId)
        }

        PickerCustom {}
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: Config.appearance.spacing.sm
        Layout.rightMargin: Config.appearance.spacing.sm
        spacing: Config.appearance.spacing.lg

        ShinySwitch {
          id: allowRestoreTokenSwitch
          sCheckedIcon.name: "check"
          sUncheckedIcon.name: "close"

          Synchronizer on checked {
            property alias source: root.allowRestoreToken
          }
        }

        ColumnLayout {
          spacing: 0

          ShinyText {
            text: "Allow restore token"
            font.pointSize: Config.appearance.font.size.sm
          }

          ShinyText {
            text: "Allow application to reuse this permission later without asking again"
            font.pointSize: Config.appearance.font.size.xs
            color: Config.appearance.color.overSurfaceVariant
          }
        }

        Item {
          Layout.fillWidth: true
        }

        ShinyButton {
          Layout.alignment: Qt.AlignRight
          variant: ShinyButton.Variant.Secondary
          text: "Cancel"

          onClicked: root.cancelled()
        }
      }
    }

    Component.onCompleted: screen = Helpers.focusedShellScreen()
  }
}
