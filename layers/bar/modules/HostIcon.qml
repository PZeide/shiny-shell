pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

ShinyText {
  text: Host.osIcon
  font.family: Config.appearance.font.family.iconNerd
}
