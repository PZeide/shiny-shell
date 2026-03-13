pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Shiny.Launcher
import Shiny.Launcher.Plugins
import qs.config

LauncherDelegate {
  id: root

  property int selectedItemIndex: 0

  input: ""
  maxItems: Config.launcher.maxItems
  plugins: [applicationsLoader.item, calculatorLoader.item, webSearchLoader.item].filter(p => p !== null)

  onResultChanged: selectedItemIndex = 0

  function tryDecrementSelectedIndex(shouldLoop = false) {
    if (selectedItemIndex > 0) {
      selectedItemIndex--;
    } else if (shouldLoop) {
      selectedItemIndex = result.rowCount() - 1;
    }
  }

  function tryIncrementSelectedIndex(shouldLoop = false) {
    if (result.rowCount() > selectedItemIndex + 1) {
      selectedItemIndex++;
    } else if (shouldLoop) {
      selectedItemIndex = 0;
    }
  }

  function invokeElement(index: int) {
    if (result.rowCount() <= index)
      return;

    result.invoke(index);
  }

  function reset() {
    input = "";
    selectedItemIndex = 0;
  }

  property Loader applicationsLoader: Loader {
    active: true
    sourceComponent: ApplicationsPlugin {
      applications: DesktopEntries.applications.values // qmllint disable incompatible-type
      useSystemd: Config.launcher.applications.useSystemd
      terminalCommand: Config.launcher.applications.terminal
      scoreThreshold: Config.launcher.applications.scoreThreshold
      scorePrefixBoost: Config.launcher.applications.scorePrefixBoost
    }
  }

  property Loader calculatorLoader: Loader {
    active: Config.launcher.calculator.enabled
    sourceComponent: CalculatorPlugin {}
  }

  property Loader webSearchLoader: Loader {
    active: Config.launcher.webSearch.enabled
    sourceComponent: WebSearchPlugin {
      searchUrl: Config.launcher.webSearch.url
    }
  }
}
