pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import qs.config
import qs.components
import qs.utils
import qs.utils.animations

T.ToolTip {
  id: root

  enum Placement {
    Top,
    Bottom,
    Left,
    Right
  }

  property int placement: ShinyTooltip.Placement.Top

  x: {
    if (!parent)
      return 0;

    switch (placement) {
    case ShinyTooltip.Placement.Top:
    case ShinyTooltip.Placement.Bottom:
      return (parent.width - width) / 2;
    case ShinyTooltip.Placement.Left:
      return -width - leftMargin;
    case ShinyTooltip.Placement.Right:
      return parent.width + rightMargin;
    }
  }

  y: {
    if (!parent)
      return 0;

    switch (placement) {
    case ShinyTooltip.Placement.Top:
      return -height - topMargin;
    case ShinyTooltip.Placement.Bottom:
      return parent.height + bottomMargin;
    case ShinyTooltip.Placement.Left:
    case ShinyTooltip.Placement.Right:
      return (parent.height - height) / 2;
    }
  }

  margins: Config.appearance.spacing.xxs
  implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
  implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
  verticalPadding: Config.appearance.padding.xs
  horizontalPadding: Config.appearance.padding.sm
  closePolicy: T.Popup.NoAutoClose
  modal: false
  delay: 300
  font.family: Config.appearance.font.family.sans
  font.pointSize: Config.appearance.font.size.sm

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
