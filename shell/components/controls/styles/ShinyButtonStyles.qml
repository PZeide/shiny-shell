pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import qs.components.controls
import qs.config
import qs.utils

Singleton {
  readonly property var configurations: ({
      // Primary
      [ShinyButton.Variant.Primary]: {
        default: {
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
        unchecked: {
          background: {
            default: Config.appearance.color.surfaceContainer,
            hover: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.3),
            down: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.4),
            disabled: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.4)
          },
          content: {
            default: Config.appearance.color.overSurface,
            disabled: Colors.transparentize(Config.appearance.color.overSurface, 0.3)
          }
        }
      },
      // Secondary
      [ShinyButton.Variant.Secondary]: {
        default: {
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
        unchecked: {
          background: {
            default: Config.appearance.color.surfaceContainer,
            hover: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.3),
            down: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.4),
            disabled: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.4)
          },
          content: {
            default: Config.appearance.color.overSurface,
            disabled: Colors.transparentize(Config.appearance.color.overSurface, 0.3)
          }
        }
      },
      // Ghost
      [ShinyButton.Variant.Ghost]: {
        default: {
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
        unchecked: {
          background: {
            default: "transparent",
            hover: Colors.transparentize(Config.appearance.color.primary, 0.92),
            down: Colors.transparentize(Config.appearance.color.primary, 0.85),
            disabled: "transparent"
          },
          content: {
            default: Config.appearance.color.overSurface,
            disabled: Colors.transparentize(Config.appearance.color.overSurface, 0.3)
          }
        }
      },
      // Danger
      [ShinyButton.Variant.Danger]: {
        default: {
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
        },
        unchecked: {
          background: {
            default: Config.appearance.color.surfaceContainer,
            hover: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.3),
            down: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.4),
            disabled: Colors.transparentize(Config.appearance.color.surfaceContainer, 0.4)
          },
          content: {
            default: Config.appearance.color.overSurface,
            disabled: Colors.transparentize(Config.appearance.color.overSurface, 0.3)
          }
        }
      }
    })
}
