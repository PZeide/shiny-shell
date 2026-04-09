import QtQuick
import QtQuick.Templates as T
import Shiny.Helpers
import qs.config
import qs.components
import qs.components.controls.styles
import qs.utils
import qs.utils.animations

T.Switch {
  id: root

  enum Variant {
    Primary,
    Secondary,
    Tertiary
  }

  property int variant: ShinySwitch.Variant.Primary
  readonly property var configuration: ShinySwitchStyles.configurations[variant]
  property icon sIcon: Helpers.emptyIcon()
  property alias sIconFont: icon.font
  readonly property bool hasIcon: sIcon.name !== ""
  property icon sCheckedIcon: Helpers.emptyIcon()
  property alias sCheckedIconFont: checkedIcon.font
  readonly property bool hasCheckedIcon: sCheckedIcon.name !== ""
  property icon sUncheckedIcon: Helpers.emptyIcon()
  property alias sUncheckedIconFont: uncheckedIcon.font
  readonly property bool hasUncheckedIcon: sUncheckedIcon.name !== ""

  implicitWidth: 40 + leftPadding + rightPadding
  implicitHeight: 18 + topPadding + bottomPadding
  padding: Config.appearance.padding.xxs

  background: ShinyRectangle {
    id: background
    radius: Config.appearance.rounding.full

    color: {
      if (root.enabled) {
        return root.checked ? root.configuration.button.checked : root.configuration.button.unchecked;
      } else {
        return root.checked ? root.configuration.button.disabledChecked : root.configuration.button.disabledUnchecked;
      }
    }
  }

  indicator: ShinyRectangle {
    radius: Config.appearance.rounding.full
    color: root.enabled ? root.configuration.indicator.default : root.configuration.indicator.disabled
    width: 25
    height: root.implicitHeight - root.topPadding - root.bottomPadding
    x: root.checked ? root.width - width - root.rightPadding : root.leftPadding
    y: root.topPadding

    Behavior on x {
      EffectNumberAnimation {}
    }

    ShinyIcon {
      id: icon
      anchors.fill: parent
      visible: root.hasIcon
      icon: root.sIcon.name
      fill: root.sIcon.fill
      grade: root.sIcon.grade
      color: root.enabled ? root.configuration.icon.default : root.configuration.icon.disabled
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    ShinyIcon {
      id: checkedIcon
      anchors.fill: parent
      visible: root.hasCheckedIcon && root.checked
      icon: root.sCheckedIcon.name
      fill: root.sCheckedIcon.fill
      grade: root.sCheckedIcon.grade
      color: root.enabled ? root.configuration.icon.default : root.configuration.icon.disabled
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    ShinyIcon {
      id: uncheckedIcon
      anchors.fill: parent
      visible: root.hasUncheckedIcon && !root.checked
      icon: root.sUncheckedIcon.name
      fill: root.sUncheckedIcon.fill
      grade: root.sUncheckedIcon.grade
      color: root.enabled ? root.configuration.icon.default : root.configuration.icon.disabled
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
  }

  Component.onCompleted: {
    const hasBothStateIcons = root.hasCheckedIcon && root.hasUncheckedIcon;
    const hasAnyStateIcon = root.hasCheckedIcon || root.hasUncheckedIcon;

    if (hasAnyStateIcon && !hasBothStateIcons) {
      console.warn("sCheckedIcon and sUncheckedIcon should both be set");
    }

    if (hasBothStateIcons && root.hasIcon) {
      console.warn("You cannot have both an icon and checked/unchecked icons");
    }
  }
}
