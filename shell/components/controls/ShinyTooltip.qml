pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.config
import qs.components
import qs.utils
import qs.utils.animations

Item {
  id: root

  enum Placement {
    Top,
    Bottom,
    Left,
    Right
  }

  property Item anchorItem: parent
  property int placement: ShinyTooltip.Placement.Top
  property real placementMargin: Config.appearance.spacing.xxs
  property string text
  property int delay: 300
  property font font: Qt.font({
    family: Config.appearance.font.family.sans,
    pointSize: Config.appearance.font.size.sm
  })

  property real verticalPadding: Config.appearance.padding.xs
  property real horizontalPadding: Config.appearance.padding.sm

  property bool showInternal: false
  property real tooltipOpacity: showInternal ? 1 : 0

  visible: false

  onVisibleChanged: {
    if (visible) {
      showTimer.restart();
    } else {
      showTimer.stop();
      showInternal = false;
    }
  }

  Behavior on tooltipOpacity {
    EffectNumberAnimation {}
  }

  Timer {
    id: showTimer

    interval: Math.max(0, root.delay)
    onTriggered: root.showInternal = root.visible && root.text !== ""
  }

  TextMetrics {
    id: textMetrics

    text: root.text
    font: root.font
  }

  PopupWindow {
    id: popup

    implicitWidth: Math.ceil(textMetrics.advanceWidth) + root.horizontalPadding * 2
    implicitHeight: Math.ceil(textMetrics.height) + root.verticalPadding * 2
    color: "transparent"
    visible: root.tooltipOpacity > 0
    grabFocus: false

    anchor {
      window: root.anchorItem ? root.anchorItem.QsWindow.window : null
      adjustment: PopupAdjustment.None
      gravity: Edges.Bottom | Edges.Right

      onAnchoring: {
        if (!root.anchorItem)
          return;

        let x = 0;
        let y = 0;

        switch (root.placement) {
        case ShinyTooltip.Placement.Top:
          x = (root.anchorItem.width - popup.width) / 2;
          y = -popup.height - root.placementMargin;
          break;
        case ShinyTooltip.Placement.Bottom:
          x = (root.anchorItem.width - popup.width) / 2;
          y = root.anchorItem.height + root.placementMargin;
          break;
        case ShinyTooltip.Placement.Left:
          x = -popup.width - root.placementMargin;
          y = (root.anchorItem.height - popup.height) / 2;
          break;
        case ShinyTooltip.Placement.Right:
          x = root.anchorItem.width + root.placementMargin;
          y = (root.anchorItem.height - popup.height) / 2;
          break;
        }

        const position = root.anchorItem.QsWindow.contentItem.mapFromItem(root.anchorItem, x, y);
        popup.anchor.rect.x = Math.round(position.x);
        popup.anchor.rect.y = Math.round(position.y);
      }
    }

    ShinyRectangle {
      anchors.fill: parent
      opacity: root.tooltipOpacity
      color: Config.appearance.color.surfaceContainerHighest
      radius: Config.appearance.rounding.sm
      border.width: 1
      border.color: Colors.transparentize(Config.appearance.color.outline, 0.5)

      transform: Scale {
        origin.x: popup.width / 2
        origin.y: popup.height / 2
        xScale: 0.85 + root.tooltipOpacity * 0.15
        yScale: xScale
      }

      ShinyText {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        text: root.text
        font: root.font
        color: Config.appearance.color.overSurface
        wrapMode: Text.NoWrap
        maximumLineCount: 1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
  }
}
