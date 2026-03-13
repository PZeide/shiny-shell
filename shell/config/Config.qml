pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
  id: root

  property alias appearance: adapter.appearance
  property alias brightness: adapter.brightness
  property alias launcher: adapter.launcher
  property alias locale: adapter.locale
  property alias lockScreen: adapter.lockScreen
  property alias notification: adapter.notification
  property alias overview: adapter.overview
  property alias player: adapter.player
  property alias polkit: adapter.polkit
  property alias session: adapter.session
  property alias wallpaper: adapter.wallpaper

  FileView {
    path: `${Paths.configUrl}/${Environment.isDev ? "config-dev.json" : "config.json"}`
    watchChanges: true
    onFileChanged: reload()
    onAdapterUpdated: writeAdapter()

    JsonAdapter { // qmllint disable unresolved-type
      id: adapter

      property AppearanceConfig appearance: AppearanceConfig {}
      property BrightnessConfig brightness: BrightnessConfig {}
      property LauncherConfig launcher: LauncherConfig {}
      property LocaleConfig locale: LocaleConfig {}
      property LockScreenConfig lockScreen: LockScreenConfig {}
      property NotificationConfig notification: NotificationConfig {}
      property OverviewConfig overview: OverviewConfig {}
      property PlayerConfig player: PlayerConfig {}
      property PolkitConfig polkit: PolkitConfig {}
      property SessionConfig session: SessionConfig {}
      property WallpaperConfig wallpaper: WallpaperConfig {}
    }
  }
}
