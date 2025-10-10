pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Shiny
import qs.layers.launcher.models
import qs.config

LauncherPlugin {
  readonly property list<DesktopEntry> entries: DesktopEntries.applications.values

  displayName: "Applications"
  prefix: ""

  function filter(input: string): var {
    const result = FuzzyEngine.sort(input, entries, [
      {
        property: "name",
        weight: 3.0
      },
      {
        property: "genericName",
        weight: 1.0
      }
    ], Config.launcher.maxItems);

    return result.map(entry => {
      const descriptor = {
        icon: entry.icon,
        name: entry.name,
        extra: entry
      };

      if (entry.description) {
        descriptor.description = entry.description;
      }

      return descriptorFactory.createObject(this, descriptor);
    });
  }
}
