import QtQuick
import QtQuick.Controls
import qs.config
import qs.components
import qs.components.effects
import qs.utils.animations

ToolTip {
  id: root

  verticalPadding: 2
  horizontalPadding: 2
  font.family: Config.appearance.font.family.sans
  font.pixelSize: Config.appearance.font.size.sm

  background: ShinyElevatedLayer {
    target: root.contentItem
  }

  contentItem: ShinyRectangle {
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter

    color: Config.appearance.color.inverseSurface
    radius: Config.appearance.rounding.xs
    opacity: root.visible ? 1 : 0
    implicitWidth: root.visible ? text.implicitWidth * root.horizontalPadding : 0
    implicitHeight: root.visible ? text.implicitHeight * root.verticalPadding : 0
    clip: true

    Behavior on implicitWidth {
      EffectNumberAnimation {}
    }

    Behavior on implicitHeight {
      EffectNumberAnimation {}
    }

    Behavior on opacity {
      EffectNumberAnimation {}
    }

    ShinyText {
      id: text
      anchors.centerIn: parent
      text: root.text
      font: root.font
      color: Config.appearance.color.inverseOverSurface
      wrapMode: Text.Wrap
    }
  }
}
