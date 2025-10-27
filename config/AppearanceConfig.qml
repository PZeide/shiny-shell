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
    property color primary: "#ffb3b6"
    property color overPrimary: "#561d23"
    property color primaryContainer: "#723338"
    property color overPrimaryContainer: "#ffdada"
    property color primaryFixed: "#ffdada"
    property color primaryFixedDim: "#ffb3b6"
    property color overPrimaryFixed: "#3b080f"
    property color overPrimaryFixedVariant: "#723338"

    property color secondary: "#e6bdbd"
    property color overSecondary: "#44292a"
    property color secondaryContainer: "#5d3f40"
    property color overSecondaryContainer: "#ffdada"
    property color secondaryFixed: "#ffdada"
    property color secondaryFixedDim: "#e6bdbd"
    property color overSecondaryFixed: "#2c1516"
    property color overSecondaryFixedVariant: "#5d3f40"

    property color tertiary: "#e6c08d"
    property color overTertiary: "#432c06"
    property color tertiaryContainer: "#5c421a"
    property color overTertiaryContainer: "#ffddb2"
    property color tertiaryFixed: "#ffddb2"
    property color tertiaryFixedDim: "#e6c08d"
    property color overTertiaryFixed: "#291800"
    property color overTertiaryFixedVariant: "#5c421a"

    property color error: "#ffb4ab"
    property color overError: "#690005"
    property color errorContainer: "#93000a"
    property color overErrorContainer: "#ffdad6"

    property color surfaceDim: "#1a1111"
    property color surface: "#1a1111"
    property color surfaceBright: "#413737"
    property color surfaceVariant: "#524343"
    property color surfaceContainerLowest: "#140c0c"
    property color surfaceContainerLow: "#22191a"
    property color surfaceContainer: "#271d1d"
    property color surfaceContainerHigh: "#322828"
    property color surfaceContainerHighest: "#3d3232"
    property color overSurface: "#f0dede"
    property color overSurfaceVariant: "#d7c1c1"

    property color outline: "#9f8c8c"
    property color outlineVariant: "#524343"

    property color inverseSurface: "#f0dede"
    property color inverseOverSurface: "#382e2e"
    property color inversePrimary: "#8f4a4e"

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
