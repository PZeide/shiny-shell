pragma Singleton
pragma ComponentBehavior: Bound

import qs.layers.launcher.models

LauncherPlugin {
  displayName: "Calculator"
  prefix: "="

  function filter(input: string): var {
    return [
      {}
    ];
  }
}
