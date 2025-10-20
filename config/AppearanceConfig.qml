pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property ColorConfig color: ColorConfig {}
  property FontConfig font: FontConfig {}
  property RoundingConfig rounding: RoundingConfig {}
  property AnimConfig anim: AnimConfig {}

  component ColorConfig: JsonObject {
    property color bgPrimary: "#1a1111"
    property color bgSecondary: "#271d1d"
    property color bgSelection: "#3d3232"

    property color fgPrimary: "#f0dede"
    property color fgSecondary: "#d7c1c1"

    property color accentPrimary: "#ffb4ab"
    property color accentSecondary: "#e6c18d"

    property color bgError: "#ef4444"
    property color bgWarning: "#efb100"
  }

  component FontConfig: JsonObject {
    property FontFamilyConfig family: FontFamilyConfig {}
    property FontSizeConfig size: FontSizeConfig {}
  }

  component FontFamilyConfig: JsonObject {
    property string sans: "Poppins"
    property string mono: "Iosevka"
    property string iconNerd: "Symbols Nerd Font"
    property string iconMaterial: "Material Symbols Rounded"
  }

  component FontSizeConfig: JsonObject {
    property int xs: 9
    property int sm: 10
    property int md: 12
    property int lg: 15
    property int xl: 18
    property int xxl: 28
  }

  component RoundingConfig: JsonObject {
    property int xs: 9
    property int sm: 12
    property int md: 17
    property int lg: 25
    property int full: 1000
    property int corner: 22
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
