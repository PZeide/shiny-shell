pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import Shiny.Helpers
import qs.components
import qs.config
import qs.utils
import qs.utils.animations

T.MenuItem {
  id: root

  property icon sIcon: Helpers.emptyIcon()
  property alias sIconFont: icon.font
  readonly property bool hasIcon: sIcon.name !== ""

  implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
  implicitHeight: 28 + topPadding + bottomPadding
  verticalPadding: Config.appearance.padding.xs
  horizontalPadding: Config.appearance.padding.sm
  implicitTextPadding: (icon.visible ? (icon.implicitWidth + spacing) : 0) + (checkCircle.visible ? (checkCircle.implicitWidth + spacing) : 0)
  spacing: Config.appearance.spacing.xs
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.md

  background: ShinyRectangle {
    radius: Config.appearance.rounding.xs

    color: {
      if (!root.enabled) {
        return "transparent";
      } else if (root.down) {
        return Colors.transparentize(Config.appearance.color.primary, 0.85);
      } else if (root.hovered) {
        return Colors.transparentize(Config.appearance.color.primary, 0.92);
      } else {
        return "transparent";
      }
    }
  }

  contentItem: RowLayout {
    anchors.verticalCenter: parent.verticalCenter
    spacing: root.spacing

    ShinyIcon {
      id: icon
      Layout.alignment: Qt.AlignLeft
      visible: root.hasIcon && !root.checkable
      icon: root.sIcon.name
      fill: root.sIcon.fill
      grade: root.sIcon.grade
      font.pointSize: Config.appearance.font.size.lg
      color: root.enabled ? Config.appearance.color.overSurface : Colors.transparentize(Config.appearance.color.overSurface, 0.3)
    }

    ShinyRectangle {
      id: checkCircle
      visible: root.checkable
      border.width: 1
      radius: Config.appearance.rounding.full
      implicitWidth: 16
      implicitHeight: 16

      border.color: {
        if (!root.checked) {
          return root.enabled ? Config.appearance.color.outline : Colors.transparentize(Config.appearance.color.outline, 0.3);
        } else {
          return "transparent";
        }
      }

      color: {
        if (root.checked) {
          return root.enabled ? Config.appearance.color.primary : Colors.transparentize(Config.appearance.color.primary, 0.3);
        } else {
          return "transparent";
        }
      }

      ShinyIcon {
        anchors.centerIn: parent
        visible: root.checked
        icon: "check"
        color: root.enabled ? Config.appearance.color.overPrimary : Colors.transparentize(Config.appearance.color.overPrimary, 0.3)
      }
    }

    ShinyText {
      Layout.fillWidth: true
      text: root.text
      font: root.font
      color: root.enabled ? Config.appearance.color.overSurface : Colors.transparentize(Config.appearance.color.overSurface, 0.3)
      leftPadding: root.textPadding - root.implicitTextPadding
      wrapMode: Text.NoWrap
      elide: Text.ElideRight
    }

    ShinyIcon {
      Layout.alignment: Qt.AlignRight
      visible: root.subMenu !== null
      icon: "chevron_right"
      font.pointSize: Config.appearance.font.size.lg
      color: root.enabled ? Config.appearance.color.overSurface : Colors.transparentize(Config.appearance.color.overSurface, 0.3)
    }
  }
}
