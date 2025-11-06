pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property ColorConfig color: ColorConfig {}
  property FontConfig font: FontConfig {}
  property RoundingConfig rounding: RoundingConfig {}
  property PaddingConfig padding: PaddingConfig {}
  property SpacingConfig spacing: SpacingConfig {}
  property AnimConfig anim: AnimConfig {}

  // https://m3.material.io/styles/color/static/baseline
  component ColorConfig: JsonObject {
    property color primary: "#dcb9f8"
    property color overPrimary: "#3f2358"
    property color primaryContainer: "#573a70"
    property color overPrimaryContainer: "#f1daff"
    property color primaryFixed: "#f1daff"
    property color primaryFixedDim: "#dcb9f8"
    property color overPrimaryFixed: "#290c41"
    property color overPrimaryFixedVariant: "#573a70"

    property color secondary: "#d1c1d9"
    property color overSecondary: "#372c3f"
    property color secondaryContainer: "#4e4256"
    property color overSecondaryContainer: "#eeddf6"
    property color secondaryFixed: "#eeddf6"
    property color secondaryFixedDim: "#d1c1d9"
    property color overSecondaryFixed: "#211829"
    property color overSecondaryFixedVariant: "#4e4256"

    property color tertiary: "#f3b7bc"
    property color overTertiary: "#4c252a"
    property color tertiaryContainer: "#663a3f"
    property color overTertiaryContainer: "#ffdadc"
    property color tertiaryFixed: "#ffdadc"
    property color tertiaryFixedDim: "#f3b7bc"
    property color overTertiaryFixed: "#321015"
    property color overTertiaryFixedVariant: "#663a3f"

    property color error: "#ffb4ab"
    property color overError: "#690005"
    property color errorContainer: "#93000a"
    property color overErrorContainer: "#ffdad6"

    property color surfaceDim: "#151217"
    property color surface: "#151217"
    property color surfaceBright: "#3c383e"
    property color surfaceVariant: "#4b454d"
    property color surfaceContainerLowest: "#100d12"
    property color surfaceContainerLow: "#1e1a20"
    property color surfaceContainer: "#221e24"
    property color surfaceContainerHigh: "#2c292e"
    property color surfaceContainerHighest: "#373339"
    property color overSurface: "#e8e0e8"
    property color overSurfaceVariant: "#cdc4ce"

    property color outline: "#968e98"
    property color outlineVariant: "#4b454d"

    property color inverseSurface: "#e8e0e8"
    property color inverseOverSurface: "#332f35"
    property color inversePrimary: "#705289"

    property color shadow: "#000000"
    property color scrim: "#000000"
  }

  component FontConfig: JsonObject {
    property FontFamilyConfig family: FontFamilyConfig {}
    property FontSizeConfig size: FontSizeConfig {}
  }

  component FontFamilyConfig: JsonObject {
    property string sans: "Vegur"
    property string mono: "Iosevka"
    property string iconNerd: "Symbols Nerd Font"
    property string iconMaterial: "Material Symbols Rounded"
  }

  component FontSizeConfig: JsonObject {
    property int xs: 9
    property int sm: 11
    property int md: 12
    property int lg: 15
    property int xl: 18
    property int xxl: 28
    property int huge: 84
  }

  component RoundingConfig: JsonObject {
    property int xxs: 3
    property int xs: 9
    property int sm: 12
    property int md: 17
    property int lg: 25
    property int full: 1000
    property int corner: 18
  }

  component SpacingConfig: JsonObject {
    property int xxs: 3
    property int xs: 7
    property int sm: 10
    property int md: 12
    property int lg: 15
    property int xl: 20
    property int xxl: 25
  }

  component PaddingConfig: JsonObject {
    property int xs: 5
    property int sm: 7
    property int md: 10
    property int lg: 12
    property int xl: 15
  }

  component AnimConfig: JsonObject {
    property AnimCurvesConfig curves: AnimCurvesConfig {}
    property AnimDurationsConfig durations: AnimDurationsConfig {}
  }

  component AnimCurvesConfig: JsonObject {
    property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
    property list<real> standard: [0.2, 0, 0, 1, 1, 1]
    property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
    property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
    property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
    property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    property list<real> expressiveEffect: [0.34, 0.8, 0.34, 1, 1, 1]
  }

  component AnimDurationsConfig: JsonObject {
    property int sm: 200
    property int md: 400
    property int lg: 600
    property int xl: 1000
    property int expressiveFastSpatial: 350
    property int expressiveDefaultSpatial: 500
    property int expressiveEffect: 200
  }
}
