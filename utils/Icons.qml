pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  function findFromClass(clazz: string): string {
    if (!clazz)
      return "image-missing";

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

    return "image-missing";
  }

  function getSinkVolumeIcon(volume: real, muted: bool): string {
    if (muted)
      return "no_sound";

    if (volume >= 0.5)
      return "volume_up";

    if (volume > 0)
      return "volume_down";

    return "volume_mute";
  }

  function getSourceVolumeIcon(volume: real, muted: bool): string {
    if (!muted && volume > 0)
      return "mic";

    return "mic_off";
  }

  function getBrightnessIcon(brightness: real): string {
    return `brightness_${(Math.round(brightness * 6) + 1)}`;
  }
}
