pragma ComponentBehavior: Bound

import qs.layers.osd
import qs.services
import qs.utils

OsdTypeWrapper {
  icon: Icons.getSinkVolumeIcon(Audio.sinkVolume, Audio.sinkMuted)
  value: Audio.sinkVolume

  onSliderValueChanged: value => {
    Audio.defaultSink.audio.volume = value;
  }
}
