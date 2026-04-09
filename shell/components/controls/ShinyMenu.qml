pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import qs.components
import qs.config
import qs.utils
import qs.utils.animations

T.Menu {
  id: root
  implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
  implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
  verticalPadding: Config.appearance.padding.sm
  horizontalPadding: Config.appearance.padding.sm
  leftInset: 1
  rightInset: 1
  closePolicy: T.Popup.CloseOnPressOutside | T.Popup.CloseOnEscape
  modal: false
  font.family: Config.appearance.font.family.sans
  font.weight: Font.Bold
  font.pointSize: Config.appearance.font.size.xs

  background: ShinyRectangle {
    color: Config.appearance.color.surfaceContainerHighest
    radius: Config.appearance.rounding.md
    border.width: 1
    border.color: Colors.transparentize(Config.appearance.color.outline, 0.5)
  }

  contentItem: ColumnLayout {
    ShinyText {
      id: titleText
      Layout.leftMargin: Config.appearance.spacing.xs
      visible: root.title !== ""
      text: root.title
      color: Config.appearance.color.overSurfaceVariant
      font: root.font
    }

    ListView {
      readonly property real biggestImplicitWidth: {
        let max = 0;
        for (let i = 0; i < count; ++i) {
          const item = itemAtIndex(i);
          if (item && item.implicitWidth > max)
            max = item.implicitWidth;
        }

        return max;
      }

      interactive: false
      implicitWidth: Math.max(Math.min(biggestImplicitWidth, 240), titleText.implicitWidth + titleText.Layout.leftMargin)
      implicitHeight: contentHeight
      model: root.contentModel
      spacing: Config.appearance.spacing.xxs
    }
  }

  enter: Transition {
    EffectNumberAnimation {
      property: "opacity"
      from: 0
      to: 1
    }

    EffectNumberAnimation {
      property: "scale"
      from: 0.95
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
      to: 0.95
    }
  }

  delegate: ShinyMenuItem {}
}
