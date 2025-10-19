pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Shiny.Launcher
import Shiny.Launcher.Plugins
import qs.config

LauncherDelegate {
  id: root
  maxItems: Config.launcher.maxItems

  plugins: {
    const result = [applicationsPlugin];

    if (Config.launcher.calculator.enabled)
      result.push(calculatorPlugin);

    if (Config.launcher.webSearch.enabled)
      result.push(webSearchPlugin);

    return result;
  }

  property Item pluginsContainer: Item {
    ApplicationsPlugin {
      id: applicationsPlugin

      // qmllint-ignore the conversion will be correctly done
      applications: DesktopEntries.applications.values
      useSystemd: Config.launcher.applications.useSystemd
      terminalCommand: Config.launcher.applications.terminal
      scoreThreshold: Config.launcher.applications.scoreThreshold
      scorePrefixBoost: Config.launcher.applications.scorePrefixBoost
    }

    CalculatorPlugin {
      id: calculatorPlugin
    }

    WebSearchPlugin {
      id: webSearchPlugin
      searchUrl: Config.launcher.webSearch.url
    }
  }
}
