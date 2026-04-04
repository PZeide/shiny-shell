import QtQuick
import QtQuick.Controls as C
import qs.config
import qs.components
import qs.utils
import qs.utils.animations

C.ToolTip {
  id: root

  verticalPadding: Config.appearance.padding.xs
  horizontalPadding: Config.appearance.padding.sm
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.sm
  closePolicy: C.Popup.NoAutoClose
  modal: false
  delay: 300

  background: ShinyRectangle {
    color: Config.appearance.color.surfaceContainerHighest
    radius: Config.appearance.rounding.sm
    border.width: 1
    border.color: Colors.transparentize(Config.appearance.color.outline, 0.5)
  }

  contentItem: ShinyText {
    text: root.text
    font: root.font
    color: Config.appearance.color.overSurface
    wrapMode: Text.NoWrap
    maximumLineCount: 1
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  enter: Transition {
    EffectNumberAnimation {
      property: "opacity"
      from: 0
      to: 1
    }

    EffectNumberAnimation {
      property: "scale"
      from: 0.85
      to: 1
    }
  }

  exit: Transition {
    EffectNumberAnimation {
      property: "opacity"
      from: 1
      to: 0
    }

    EffectNumberAnimation {
      property: "scale"
      from: 1
      to: 0.85
    }
  }
}
