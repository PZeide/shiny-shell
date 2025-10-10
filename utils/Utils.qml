pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  function deepEquals(a: var, b: var): bool {
    if (a === b)
      return true;

    if (typeof a !== "object" || typeof b !== "object" || a === null || b === null)
      return false;

    const keysA = Object.keys(a);
    const keysB = Object.keys(b);

    if (keysA.length !== keysB.length)
      return false;

    for (let key of keysA) {
      if (!(key in b) || !deepEquals(a[key], b[key]))
        return false;
    }

    return true;
  }
}
