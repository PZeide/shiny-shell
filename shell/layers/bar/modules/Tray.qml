pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.DBusMenu
import Quickshell.Services.SystemTray
import qs.config
import qs.components
import qs.components.controls
import qs.layers.bar

Loader {
  active: SystemTray.items.values.length > 0
  width: parent.width
  height: (item as Item)?.implicitHeight || 0

  sourceComponent: BarModuleWrapper {
    id: root

    contentItem: ColumnLayout {
      id: layout
      anchors.centerIn: parent
      spacing: Config.appearance.spacing.xs

      Repeater {
        model: SystemTray.items

        delegate: Item {
          id: trayItem

          required property SystemTrayItem modelData

          implicitWidth: layout.parent.implicitWidth
          implicitHeight: layout.parent.implicitWidth

          Image {
            anchors.centerIn: parent
            asynchronous: true
            sourceSize.width: trayItem.width
            sourceSize.height: trayItem.height
            source: trayItem.modelData.icon
          }

          ShinyInteractiveLayer {
            id: layer
            anchors.fill: parent
            layerRadius: Config.appearance.rounding.xs

            onClicked: {
              if (trayItem.modelData.hasMenu) {
                if (menu.opened) {
                  menu.close();
                } else {
                  menu.open();
                }
              } else {
                trayItem.modelData.activate();
              }
            }
          }

          /*ShinyTooltip {
            visible: layer.containsMouse &&  !== ""
            text: trayItem.modelData.tooltipTitle
            popupType: Popup.Window

            // Maybe like the context menu we want to show on top? Or maybe keep the way it is so it does not overlap the context menu
            }*/

          QsMenuOpener {
            id: menuOpener
            menu: trayItem.modelData.menu
          }

          ShinyMenu {
            id: menu
            title: trayItem.modelData.title !== "" ? trayItem.modelData.title : trayItem.modelData.tooltipTitle
            popupType: Popup.Window

            Repeater {
              model: menuOpener.children

              delegate: ShinyMenuItem {
                id: item

                required property QsMenuEntry modelData

                text: modelData.text
                checkable: modelData.buttonType !== QsMenuButtonType.None
                checked: modelData.checkState === Qt.Checked

                Loader {
                  active: item.modelData.hasChildren
                  sourceComponent: QsMenuOpener {
                    menu: item.modelData
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
