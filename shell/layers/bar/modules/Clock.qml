pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components
import qs.layers.bar

BarModuleWrapper {
  ShinyInteractiveLayer {
    id: layer
    anchors.fill: parent
    layerRadius: Config.appearance.rounding.xs
  }

  contentItem: ColumnLayout {
    spacing: Config.appearance.spacing.xs

    Repeater {
      model: Config.bar.clock.parts

      ShinyText {
        Layout.alignment: Qt.AlignHCenter

        required property string modelData
        readonly property bool isAmPm: modelData.toLowerCase() === "ap"

        text: {
          const format = Qt.formatTime(Clock.date, modelData);
          if (isAmPm) {
            if (Config.bar.clock.showApKanji) {
              return format.toLowerCase() === "am" ? "午前" : "午後";
            }

            return format;
          } else {
            return format.replace(/ (AM|PM|am|pm)/, "");
          }
        }

        font.pointSize: isAmPm ? (Config.bar.clock.showApKanji ? Config.appearance.font.size.xxs : Config.appearance.font.size.xs) : Config.appearance.font.size.lg
        font.weight: Font.DemiBold
        font.family: isAmPm && Config.bar.clock.showApKanji ? Config.appearance.font.family.jp : Config.appearance.font.family.sans
        color: isAmPm ? Config.appearance.color.primary : Config.appearance.color.overSurface
      }
    }
  }
}
