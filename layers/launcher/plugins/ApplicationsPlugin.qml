pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Shiny
import qs.layers.launcher.models

LauncherPlugin {
  displayName: "Applications"
  prefix: ""

  function filter(input: string): list<LauncherItemDescriptor> {
    return Fuzzy;
  }
}
