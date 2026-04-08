pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import qs.components.controls
import qs.config

Singleton {
  readonly property var configurations: ({
      // Primary
      [ShinySwitch.Variant.Primary]: {
        button: {
          unchecked: Config.appearance.color.surfaceContainerHigh,
          checked: Config.appearance.color.primary,
          disabledUnchecked: Config.appearance.color.surfaceContainer,
          disabledChecked: Config.appearance.color.outline
        },
        indicator: {
          default: Config.appearance.color.overSurface,
          disabled: Config.appearance.color.inverseOverSurface
        },
        icon: {
          default: Config.appearance.color.surfaceContainerHigh,
          disabled: Config.appearance.color.outline
        }
      },
      // Secondary
      [ShinySwitch.Variant.Secondary]: {
        button: {
          unchecked: Config.appearance.color.surfaceContainerHigh,
          checked: Config.appearance.color.secondary,
          disabledUnchecked: Config.appearance.color.surfaceContainer,
          disabledChecked: Config.appearance.color.outline
        },
        indicator: {
          default: Config.appearance.color.overSurface,
          disabled: Config.appearance.color.inverseOverSurface
        },
        icon: {
          default: Config.appearance.color.surfaceContainerHigh,
          disabled: Config.appearance.color.outline
        }
      },
      // Tertiary
      [ShinySwitch.Variant.Tertiary]: {
        button: {
          unchecked: Config.appearance.color.surfaceContainerHigh,
          checked: Config.appearance.color.tertiary,
          disabledUnchecked: Config.appearance.color.surfaceContainer,
          disabledChecked: Config.appearance.color.outline
        },
        indicator: {
          default: Config.appearance.color.overSurface,
          disabled: Config.appearance.color.inverseOverSurface
        },
        icon: {
          default: Config.appearance.color.surfaceContainerHigh,
          disabled: Config.appearance.color.outline
        }
      }
    })
}
