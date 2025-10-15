pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.widgets

ShinyText {
  text: Host.osIcon
  font.family: Config.appearance.font.family.iconNerd
}
