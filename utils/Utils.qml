pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  function scriptCommand(script: string, ...args): list<string> {
    return ["nu", "-n", Paths.scriptPath(script), ...args];
  }

  function extractNuError(error: string): string {
    const lines = error.split("\n");
    const marker = "Error:   x ";
    for (const line of lines) {
      const trimmed = line.trim();
      if (trimmed.startsWith(marker)) {
        return trimmed.substring(marker.length);
      }
    }

    return "Unknown error";
  }

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

  function shortDuration(seconds: int): string {
    if (seconds < 0)
      return "0:00";

    const hours = Math.floor(seconds / 3600);
    seconds %= 3600;

    const minutes = Math.floor(seconds / 60);
    seconds %= 60;

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }
  }

  function prettyDuration(seconds: int, compact = false): string {
    if (seconds < 0) {
      return "Invalid duration";
    }

    const days = Math.floor(seconds / 86400);
    seconds %= 86400;

    const hours = Math.floor(seconds / 3600);
    seconds %= 3600;

    const minutes = Math.floor(seconds / 60);
    seconds %= 60;

    const parts = [];
    if (compact) {
      if (days > 0)
        parts.push(`${days}d`);

      if (hours > 0)
        parts.push(`${hours}h`);

      if (minutes > 0)
        parts.push(`${minutes}m`);

      if (seconds > 0 || parts.length === 0)
        parts.push(`${seconds}s`);

      return parts.join(" ");
    } else {
      if (days > 0)
        parts.push(`${days} day${days > 1 ? "s" : ""}`);

      if (hours > 0)
        parts.push(`${hours} hour${hours > 1 ? "s" : ""}`);

      if (minutes > 0)
        parts.push(`${minutes} minute${minutes > 1 ? "s" : ""}`);

      if (seconds > 0 || parts.length === 0)
        parts.push(`${seconds} second${seconds !== 1 ? "s" : ""}`);

      if (parts.length > 1) {
        return parts.slice(0, -1).join(", ") + " and " + parts[parts.length - 1];
      } else {
        return parts[0];
      }
    }
  }
}
