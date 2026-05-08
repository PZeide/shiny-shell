pragma ComponentBehavior: Bound

import qs.layers.osd
import qs.services
import qs.utils

OsdTypeWrapper {
  readonly property real volume: Audio.defaultSource.audio.volume ?? 0
  readonly property bool muted: Audio.defaultSource.audio.muted ?? false

  icon: Icons.getSourceVolumeIcon(volume, muted)
  value: volume
  sliderEnabled: !muted

  onSliderValueChanged: value => Audio.defaultSource.audio.volume = value
}
