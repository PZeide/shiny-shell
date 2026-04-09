pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import qs.config
import qs.components
import qs.utils.animations

T.TabBar {
  id: root

  readonly property real biggestImplicitWidth: {
    let max = 0;
    for (let i = 0; i < count; ++i) {
      const item = itemAt(i);
      if (item && item.implicitWidth > max)
        max = item.implicitWidth;
    }

    return max;
  }

  // By default try to scale to the widest possible width, can be overridden by setting implicitWidth
  contentWidth: biggestImplicitWidth * count + (count - 1) * root.spacing
  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
  padding: Config.appearance.padding.md
  spacing: Config.appearance.spacing.xl

  background: ShinyRectangle {
    color: Config.appearance.color.surfaceContainer
    radius: Config.appearance.rounding.md
  }

  contentItem: ListView {
    model: root.contentModel
    currentIndex: root.currentIndex
    spacing: root.spacing
    orientation: ListView.Horizontal
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickIfNeeded
    snapMode: ListView.SnapToItem
    highlightFollowsCurrentItem: false

    highlight: ShinyRectangle {
      id: highlight

      readonly property real padding: Config.appearance.padding.xs

      color: Config.appearance.color.surfaceContainerHighest
      radius: Config.appearance.rounding.sm
      width: ListView.view.currentItem.width + padding * 2
      height: ListView.view.currentItem.height + padding * 2
      x: ListView.view.currentItem.x - padding
      y: ListView.view.currentItem.y - padding

      Behavior on width {
        EffectNumberAnimation {}
      }

      Behavior on x {
        EffectNumberAnimation {}
      }
    }
  }
}
