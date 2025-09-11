pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
  id: root

  property alias appearance: adapter.appearance
  property alias bar: adapter.bar
  property alias locale: adapter.locale
  property alias location: adapter.location
  property alias lockScreen: adapter.lockScreen
  property alias player: adapter.player
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
      property LocaleConfig locale: LocaleConfig {}
      property LocationConfig location: LocationConfig {}
      property LockScreenConfig lockScreen: LockScreenConfig {}
      property PlayerConfig player: PlayerConfig {}
      property WallpaperConfig wallpaper: WallpaperConfig {}
    }
  }
}
