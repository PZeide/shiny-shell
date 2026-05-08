pragma ComponentBehavior: Bound

import qs.layers.osd
import qs.services
import qs.utils

OsdTypeWrapper {
  readonly property real volume: Audio.defaultSink.audio.volume ?? 0
  readonly property bool muted: Audio.defaultSink.audio.muted ?? false

  icon: Icons.getSinkVolumeIcon(volume, muted)
  value: volume
  sliderEnabled: !muted

  onSliderValueChanged: value => Audio.defaultSink.audio.volume = value
}
