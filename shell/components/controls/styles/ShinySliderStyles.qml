pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import qs.components.controls
import qs.config
import qs.utils

Singleton {
  readonly property var configurations: ({
      // Primary
      [ShinySubtleSlider.Variant.Primary]: {
        track: {
          default: Config.appearance.color.surfaceContainer,
          disabled: Config.appearance.color.surfaceContainerLow
        },
        highlight: {
          default: Config.appearance.color.primary,
          disabled: Colors.transparentize(Config.appearance.color.primary, 0.4)
        },
        handle: {
          default: Config.appearance.color.primaryFixed,
          disabled: Colors.transparentize(Config.appearance.color.primaryFixed, 0.4)
        }
      },
      // Secondary
      [ShinySubtleSlider.Variant.Secondary]: {
        track: {
          default: Config.appearance.color.surfaceContainer,
          disabled: Config.appearance.color.surfaceContainerLow
        },
        highlight: {
          default: Config.appearance.color.secondary,
          disabled: Colors.transparentize(Config.appearance.color.secondary, 0.4)
        },
        handle: {
          default: Config.appearance.color.secondaryFixed,
          disabled: Colors.transparentize(Config.appearance.color.secondaryFixed, 0.4)
        }
      }
    })
}
