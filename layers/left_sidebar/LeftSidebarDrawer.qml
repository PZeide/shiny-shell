pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components
import qs.config
import qs.layers.left_sidebar.ai
import qs.layers.left_sidebar.booru
import qs.layers.left_sidebar.gacha

ShinyClippingRectangle {
  id: root

  readonly property list<var> elements: [
    {
      enabled: Config.leftSidebar.ai.enabled,
      id: "ai",
      name: "Intelligence",
      icon: "network_intelligence",
      component: aiComponent
    },
    {
      enabled: Config.leftSidebar.booru.enabled,
      id: "booru",
      name: "Booru",
      icon: "developer_board",
      component: booruComponent
    },
    {
      enabled: Config.leftSidebar.gacha.enabled,
      id: "gacha",
      name: "Gacha",
      icon: "stars_2",
      component: gachaComponent
    }
  ]

  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

  ColumnLayout {
    id: layout
    anchors.fill: parent
    anchors.margins: Config.appearance.spacing.sm
    spacing: 0

    NavigationBanner {
      id: navigation
      elements: root.elements.filter(e => e.enabled)
      Layout.fillWidth: true
    }

    ShinyRectangle {
      color: Config.appearance.color.surfaceBright
      Layout.fillWidth: true
      implicitHeight: 2
    }

    SwipeView {
      id: view
      currentIndex: navigation.selectedIndex
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 16
      contentChildren: root.elements.filter(e => e.enabled).map(e => e.component.createObject(this))

      onCurrentIndexChanged: navigation.selectedIndex = currentIndex
    }
  }

  Component {
    id: aiComponent
    AiPane {}
  }

  Component {
    id: booruComponent
    BooruPane {}
  }

  Component {
    id: gachaComponent
    GachaPane {}
  }
}
