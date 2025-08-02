pragma ComponentBehavior: Bound

import QtQuick
import qs.Config
import qs.Services
import qs.Widgets

ShinyText {
  text: Host.osIcon
  font.family: Config.appearance.font.family.iconNerd
}
