pragma Singleton

import Quickshell
import Quickshell.Io
import qs.Utils

Singleton {
  id: root

  property alias appearance: adapter.appearance
  property alias bar: adapter.bar
  property alias lockScreen: adapter.lockScreen
  property alias wallpaper: adapter.wallpaper

  FileView {
    path: `${Paths.configUrl}/config.json`
    watchChanges: true
    onFileChanged: reload()
    onAdapterUpdated: writeAdapter()

    JsonAdapter {
      id: adapter

      property AppearanceConfig appearance: AppearanceConfig {}
      property BarConfig bar: BarConfig {}
      property LockScreenConfig lockScreen: LockScreenConfig {}
      property WallpaperConfig wallpaper: WallpaperConfig {}
    }
  }
}
