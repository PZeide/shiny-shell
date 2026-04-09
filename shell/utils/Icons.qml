pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  function findFromClass(clazz: string): var {
    if (!clazz)
      return "image://icon/image-missing";

    let icon = Quickshell.iconPath(clazz, true);
    if (icon)
      return icon;

    const entry = DesktopEntries.heuristicLookup(clazz);
    if (entry && entry.icon) {
      icon = Quickshell.iconPath(entry.icon);
      if (icon)
        return icon;
    }

    icon = Quickshell.iconPath(clazz.toLowerCase(), true);
    if (icon)
      return icon;

    return "image://icon/image-missing";
  }
}
