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
    spacing: Config.appearance.spacing.xxs

    Repeater {
      model: Config.bar.clock.parts

      ShinyText {
        Layout.alignment: Qt.AlignHCenter

        required property string modelData
        readonly property bool isAmPm: modelData.toLowerCase() === "ap"

        text: {
          const format = Qt.formatTime(Clock.date, modelData);
          if (!isAmPm) {
            return format.replace(/ (AM|PM|am|pm)/, "");
          }

          return format;
        }

        font.pointSize: isAmPm ? Config.appearance.font.size.xs : Config.appearance.font.size.lg
        font.weight: 400
      }
    }
  }
}
