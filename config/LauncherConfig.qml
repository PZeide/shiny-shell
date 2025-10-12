pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property int maxItems: 6
  property ApplicationsConfig applications: ApplicationsConfig {}
  property CalculatorConfig calculator: CalculatorConfig {}
  property WebSearchConfig webSearch: WebSearchConfig {}

  component ApplicationsConfig: JsonObject {
    property bool useSystemd: true
    property string terminal: ""
    property real scoreThreshold: 0.6
    property real scorePrefixBoost: 0.12
  }

  component CalculatorConfig: JsonObject {
    property bool enabled: true
  }

  component WebSearchConfig: JsonObject {
    property bool enabled: true
    property string url: "https://kagi.com/search?q=%s"
  }
}
