pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import Shiny.Helpers
import qs.components
import qs.components.controls.styles
import qs.utils
import qs.utils.animations
import qs.config

T.AbstractButton {
  id: root

  enum Variant {
    Primary = 0,
    Secondary = 1,
    Ghost = 2,
    Danger = 3
  }

  property int variant: ShinyButton.Variant.Primary
  readonly property var configuration: ShinyButtonStyles.configurations[variant][root.checkable && !root.checked ? "unchecked" : "default"]
  readonly property bool square: root.display === T.AbstractButton.IconOnly
  property icon sIcon: Helpers.emptyIcon()
  property alias sIconFont: icon.font
  readonly property bool hasIcon: sIcon.name !== ""
  property alias radius: background.radius
  property alias topLeftRadius: background.topLeftRadius
  property alias topRightRadius: background.topRightRadius
  property alias bottomLeftRadius: background.bottomLeftRadius
  property alias bottomRightRadius: background.bottomRightRadius

  implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
  implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
  verticalPadding: Config.appearance.padding.sm
  horizontalPadding: root.square ? Config.appearance.padding.sm : Config.appearance.padding.md
  spacing: Config.appearance.spacing.xs

  background: ShinyRectangle {
    id: background
    radius: Config.appearance.rounding.xs

    color: {
      if (!root.enabled) {
        return root.configuration.background.disabled;
      } else if (root.down) {
        return root.configuration.background.down;
      } else if (root.hovered) {
        return root.configuration.background.hover;
      } else {
        return root.configuration.background.default;
      }
    }
  }

  contentItem: FlexboxLayout {
    anchors.centerIn: parent
    gap: root.spacing
    direction: root.display === T.AbstractButton.TextUnderIcon ? FlexboxLayout.Column : FlexboxLayout.Row
    alignItems: FlexboxLayout.AlignCenter
    justifyContent: FlexboxLayout.JustifyCenter

    ShinyIcon {
      id: icon
      Layout.preferredWidth: root.square ? Math.max(icon.implicitWidth, icon.implicitHeight) : icon.implicitWidth
      Layout.preferredHeight: root.square ? Math.max(icon.implicitWidth, icon.implicitHeight) : Math.max(icon.implicitHeight, text.implicitHeight)
      visible: root.hasIcon && root.display !== T.AbstractButton.TextOnly
      icon: root.sIcon.name
      fill: root.sIcon.fill
      grade: root.sIcon.grade
      color: root.enabled ? root.configuration.content.default : root.configuration.content.disabled
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      font.pointSize: Config.appearance.font.size.lg

      Behavior on color {
        EffectColorAnimation {}
      }
    }

    ShinyText {
      id: text
      Layout.preferredHeight: Math.max(text.implicitHeight, icon.implicitHeight)
      visible: root.text !== "" && root.display !== T.AbstractButton.IconOnly
      text: root.text
      font: root.font
      color: root.enabled ? root.configuration.content.default : root.configuration.content.disabled
      verticalAlignment: Text.AlignVCenter

      Behavior on color {
        EffectColorAnimation {}
      }
    }
  }
}
