pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
  id: root

  property alias appearance: adapter.appearance
  property alias bar: adapter.bar
  property alias brightness: adapter.brightness
  property alias launcher: adapter.launcher
  property alias locale: adapter.locale
  property alias lockScreen: adapter.lockScreen
  property alias notification: adapter.notification
  property alias player: adapter.player
  property alias polkit: adapter.polkit
  property alias regionSelector: adapter.regionSelector
  property alias screenRecorder: adapter.screenRecorder
  property alias session: adapter.session
  property alias sharePicker: adapter.sharePicker
  property alias wallpaper: adapter.wallpaper

  FileView {
    path: Quickshell.env("SHINYSHELL_CONFIG") ?? `${Paths.configUrl}/config.json`
    watchChanges: true
    onFileChanged: reload()
    onAdapterUpdated: writeAdapter()

    JsonAdapter { // qmllint disable unresolved-type
      id: adapter

      property AppearanceConfig appearance: AppearanceConfig {}
      property BarConfig bar: BarConfig {}
      property BrightnessConfig brightness: BrightnessConfig {}
      property LauncherConfig launcher: LauncherConfig {}
      property LocaleConfig locale: LocaleConfig {}
      property LockScreenConfig lockScreen: LockScreenConfig {}
      property NotificationConfig notification: NotificationConfig {}
      property PlayerConfig player: PlayerConfig {}
      property PolkitConfig polkit: PolkitConfig {}
      property RegionSelectorConfig regionSelector: RegionSelectorConfig {}
      property ScreenRecorderConfig screenRecorder: ScreenRecorderConfig {}
      property SessionConfig session: SessionConfig {}
      property SharePickerConfig sharePicker: SharePickerConfig {}
      property WallpaperConfig wallpaper: WallpaperConfig {}
    }
  }
}
