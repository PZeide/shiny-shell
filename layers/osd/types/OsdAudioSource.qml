pragma ComponentBehavior: Bound

import qs.layers.osd
import qs.services
import qs.utils

OsdTypeWrapper {
  icon: Icons.getSourceVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
  value: Audio.sourceVolume

  onSliderValueChanged: value => {
    Audio.defaultSource.audio.volume = value;
  }
}
