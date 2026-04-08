pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

T.ScrollView {
  id: root

  ShinyScrollBar.vertical: ShinyScrollBar {
    parent: root
    x: root.mirrored ? 0 : root.width - width
    y: root.topPadding
    height: root.availableHeight
    active: root.ShinyScrollBar.horizontal.active
  }

  ShinyScrollBar.horizontal: ShinyScrollBar {
    parent: root
    x: root.leftPadding
    y: root.height - height
    width: root.availableWidth
    active: root.ShinyScrollBar.vertical.active
  }
}
