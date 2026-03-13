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
    property color primary: "#ffb4a5"
    property color overPrimary: "#561f13"
    property color primaryContainer: "#733427"
    property color overPrimaryContainer: "#ffdad3"
    property color primaryFixed: "#ffdad3"
    property color primaryFixedDim: "#ffb4a5"
    property color overPrimaryFixed: "#3a0a03"
    property color overPrimaryFixedVariant: "#733427"

    property color secondary: "#e7bdb4"
    property color overSecondary: "#442a24"
    property color secondaryContainer: "#5d3f39"
    property color overSecondaryContainer: "#ffdad3"
    property color secondaryFixed: "#ffdad3"
    property color secondaryFixedDim: "#e7bdb4"
    property color overSecondaryFixed: "#2c1510"
    property color overSecondaryFixedVariant: "#5d3f39"

    property color tertiary: "#dcc48c"
    property color overTertiary: "#3d2f04"
    property color tertiaryContainer: "#554519"
    property color overTertiaryContainer: "#f9e0a6"
    property color tertiaryFixed: "#f9e0a6"
    property color tertiaryFixedDim: "#dcc48c"
    property color overTertiaryFixed: "#241a00"
    property color overTertiaryFixedVariant: "#554519"

    property color error: "#ffb4ab"
    property color overError: "#690005"
    property color errorContainer: "#93000a"
    property color overErrorContainer: "#ffdad6"

    property color surfaceDim: "#1a1110"
    property color surface: "#1a1110"
    property color surfaceBright: "#423734"
    property color surfaceVariant: "#534340"
    property color surfaceContainerLowest: "#140c0a"
    property color surfaceContainerLow: "#231917"
    property color surfaceContainer: "#271d1b"
    property color surfaceContainerHigh: "#322826"
    property color surfaceContainerHighest: "#3d3230"
    property color overSurface: "#f1dfdb"
    property color overSurfaceVariant: "#d8c2bd"

    property color outline: "#a08c88"
    property color outlineVariant: "#534340"

    property color inverseSurface: "#f1dfdb"
    property color inverseOverSurface: "#392e2c"
    property color inversePrimary: "#904b3d"

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
    property int xs: 10
    property int sm: 11
    property int md: 12
    property int lg: 14
    property int xl: 18
    property int xxl: 24
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
    property int xxs: 2
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
