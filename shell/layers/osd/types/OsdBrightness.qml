pragma ComponentBehavior: Bound

import qs.layers.osd
import qs.services
import qs.utils
import qs.config

OsdTypeWrapper {
  icon: Icons.getBrightnessIcon(Brightness.defaultDevice.brightness)
  value: Brightness.defaultDevice.brightness

  onSliderValueChanged: value => {
    if (Config.brightness.smooth) {
      Brightness.defaultDevice.commitBrightnessSmooth(value);
    } else {
      Brightness.defaultDevice.commitBrightness(value);
    }
  }
}
