pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components
import qs.layers.bar

BarModuleWrapper {
  ShinyIcon {
    icon: "location_on"
    fill: 1
    color: Config.appearance.color.primary
  }

  ShinyText {
    text: `${Location.current.city}, ${Location.current.countryName}`
    font.pointSize: Config.appearance.font.size.sm
  }
}
