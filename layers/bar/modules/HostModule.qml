pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components
import qs.layers.bar

BarModuleWrapper {
  ShinyText {
    text: Host.osIcon
    font.family: Config.appearance.font.family.iconNerd
    color: Config.appearance.color.primary
  }
}
