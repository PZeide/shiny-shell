pragma ComponentBehavior: Bound

import qs.layers.osd
import qs.services
import qs.utils

OsdTypeWrapper {
  icon: Icons.getBrightnessIcon(Brightness.userValue)
  value: Brightness.userValue

  onSliderValueChanged: value => {
    Brightness.set(value);
  }
}
