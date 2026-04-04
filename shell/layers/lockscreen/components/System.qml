pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.controls
import qs.config
import qs.services
import qs.utils.animations
import qs.layers.lockscreen.components.modules as SystemModules

ShinyRectangle {
  id: root
  implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

  RowLayout {
    id: layout
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.margins: Config.appearance.padding.lg
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    spacing: Config.appearance.padding.lg

    ShinyRectangle {
      Layout.fillHeight: true
      implicitWidth: itemsLayout.implicitWidth + Config.appearance.spacing.xs * 2
      color: Config.appearance.color.surfaceContainer
      radius: Config.appearance.rounding.xs

      RowLayout {
        id: itemsLayout
        anchors.centerIn: parent
        implicitHeight: 30
        spacing: Config.appearance.spacing.xs

        SystemModules.Audio {}
        SystemModules.NotificationIndicator {}
        SystemModules.Battery {}

        Behavior on implicitWidth {
          EffectNumberAnimation {}
        }
      }
    }

    ShinyButton {
      Layout.fillHeight: true
      Layout.preferredWidth: height
      variant: ShinyButton.Variant.Ghost
      sIcon.name: "power_settings_new"
      sIconFont.pointSize: Config.appearance.font.size.xl
      sIconFont.weight: Font.Bold

      onClicked: actionMenu.open()

      ShinyMenu {
        id: actionMenu
        x: (parent.width - width) / 2
        y: -height - layout.anchors.topMargin - Config.appearance.spacing.xxs

        ShinyMenuItem {
          text: "Shutdown"
          sIcon.name: "mode_off_on"
          onClicked: Session.shutdown()
        }

        ShinyMenuItem {
          text: "Restart"
          sIcon.name: "restart_alt"
          onClicked: Session.reboot()
        }

        ShinyMenuItem {
          text: "Sleep"
          sIcon.name: "bedtime"
          onClicked: Session.suspend()
        }
      }
    }
  }
}
