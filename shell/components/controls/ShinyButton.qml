pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates
import QtQuick.Layouts
import qs.components
import qs.utils
import qs.utils.animations
import qs.config

AbstractButton {
  id: root

  enum Variant {
    Primary = 0,
    Secondary = 1,
    Ghost = 2,
    Danger = 3
  }

  readonly property var _configurations: ({
      // Primary
      0: {
        background: {
          default: Config.appearance.color.primary,
          hover: Colors.transparentize(Config.appearance.color.primary, 0.3),
          down: Colors.transparentize(Config.appearance.color.primary, 0.4),
          disabled: Colors.transparentize(Config.appearance.color.primary, 0.4)
        },
        content: {
          default: Config.appearance.color.overPrimary,
          disabled: Colors.transparentize(Config.appearance.color.overPrimary, 0.3)
        }
      },
      // Secondary
      1: {
        background: {
          default: Config.appearance.color.secondaryContainer,
          hover: Colors.transparentize(Config.appearance.color.secondaryContainer, 0.3),
          down: Colors.transparentize(Config.appearance.color.secondaryContainer, 0.4),
          disabled: Colors.transparentize(Config.appearance.color.secondaryContainer, 0.4)
        },
        content: {
          default: Config.appearance.color.overSecondaryContainer,
          disabled: Colors.transparentize(Config.appearance.color.overSecondaryContainer, 0.3)
        }
      },
      // Ghost
      2: {
        background: {
          default: "transparent",
          hover: Colors.transparentize(Config.appearance.color.primary, 0.92),
          down: Colors.transparentize(Config.appearance.color.primary, 0.85),
          disabled: "transparent"
        },
        content: {
          default: Config.appearance.color.primary,
          disabled: Colors.transparentize(Config.appearance.color.primary, 0.3)
        }
      },
      // Danger
      3: {
        background: {
          default: Config.appearance.color.errorContainer,
          hover: Colors.transparentize(Config.appearance.color.errorContainer, 0.3),
          down: Colors.transparentize(Config.appearance.color.errorContainer, 0.4),
          disabled: Colors.transparentize(Config.appearance.color.errorContainer, 0.4)
        },
        content: {
          default: Config.appearance.color.overErrorContainer,
          disabled: Colors.transparentize(Config.appearance.color.overErrorContainer, 0.3)
        }
      }
    })

  property int variant: ShinyButton.Variant.Primary
  readonly property var configuration: _configurations[variant]
  readonly property bool hasIcon: iconName !== ""
  property string iconName: ""
  property real iconFill: 0
  property int iconGrade: 0
  property alias iconFont: icon.font
  property alias radius: backgroundRectangle.radius
  property alias topLeftRadius: backgroundRectangle.topLeftRadius
  property alias topRightRadius: backgroundRectangle.topRightRadius
  property alias bottomLeftRadius: backgroundRectangle.bottomLeftRadius
  property alias bottomRightRadius: backgroundRectangle.bottomRightRadius

  verticalPadding: Config.appearance.padding.xs
  horizontalPadding: Config.appearance.padding.sm
  spacing: Config.appearance.spacing.xs

  background: ShinyRectangle {
    id: backgroundRectangle
    anchors.fill: parent
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

    Behavior on color {
      EffectColorAnimation {}
    }
  }

  contentItem: Item {
    RowLayout {
      anchors.centerIn: parent
      spacing: root.spacing

      ShinyIcon {
        id: icon
        visible: root.hasIcon
        icon: root.iconName
        fill: root.iconFill
        grade: root.iconGrade
        font.pointSize: Config.appearance.font.size.lg
        color: root.enabled ? root.configuration.content.default : root.configuration.content.disabled

        Behavior on color {
          EffectColorAnimation {}
        }
      }

      ShinyText {
        id: text
        visible: root.text !== ""
        text: root.text
        font: root.font
        color: root.enabled ? root.configuration.content.default : root.configuration.content.disabled

        Behavior on color {
          EffectColorAnimation {}
        }
      }
    }
  }
}
