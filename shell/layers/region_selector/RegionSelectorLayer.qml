pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.services.models
import qs.components
import qs.config
import qs.utils
import qs.utils.animations

ShinyRectangle {
  id: root

  required property ShellScreen screen
  required property bool freeze
  required property bool hintWindows
  required property bool hintLayers
  readonly property int pressAndHoldInterval: 500
  readonly property int pressAndHoldThreshold: 50
  readonly property list<string> excludeLayers: ["shiny:region-selector", "shiny:inhibitor", "shiny:wallpaper", "shiny:bar", "shiny:corner-topleft", "shiny:corner-topright", "shiny:corner-bottomleft", "shiny:corner-bottomright", ...Config.regionSelector.excludeLayers]
  property bool selectionMade: false
  readonly property int hyprlandRounding: HyprCompositor.optionValueFor("decoration:rounding")
  readonly property HyprlandMonitor hyprlandMonitor: HyprCompositor.monitorFor(screen)
  readonly property list<HyprlandToplevel> windows: hyprlandMonitor.activeWorkspace?.toplevels?.values ?? []
  readonly property list<HyprlandLayer> layers: HyprCompositor.layers.filter(layer => {
    if (layer.monitor !== hyprlandMonitor) {
      return false;
    }

    if (excludeLayers.includes(layer.namespace)) {
      return false;
    }

    return true;
  })

  readonly property list<RectangularRegion> effectiveRegions: {
    let combined = [];

    if (hintLayers) {
      layers.forEach(l => combined.push({
          type: "layer",
          data: l
        }));
    }

    if (hintWindows) {
      windows.forEach(w => combined.push({
          type: "window",
          data: w
        }));
    }

    return combined.sort((a, b) => {
      const getPriority = item => {
        if (item.type === "layer") {
          if (item.data.level >= 2)
            return 10;

          if (item.data.level <= 1)
            return -10;
        }

        return 0;
      };

      const priorityA = getPriority(a);
      const priorityB = getPriority(b);

      if (priorityA !== priorityB) {
        return priorityB - priorityA;
      }

      if (a.type === "layer") {
        return b.data.level - a.data.level;
      } else {
        const winA = a.data;
        const winB = b.data;
        if (winA.lastIpcObject.floating !== winB.lastIpcObject.floating) {
          return winA.lastIpcObject.floating ? -1 : 1;
        }
        return winA.lastIpcObject.focusHistoryID - winB.lastIpcObject.focusHistoryID;
      }
    }).map(item => {
      if (item.type === "window") {
        return regionComponent.createObject(root, {
          source: "window",
          screen: root.screen,
          x: item.data.lastIpcObject.at[0],
          y: item.data.lastIpcObject.at[1],
          width: item.data.lastIpcObject.size[0],
          height: item.data.lastIpcObject.size[1]
        });
      } else if (item.type === "layer") {
        return regionComponent.createObject(root, {
          source: "layer",
          screen: root.screen,
          x: item.data.x,
          y: item.data.y,
          width: item.data.width,
          height: item.data.height
        });
      }
    });
  }

  signal selected(region: RectangularRegion)
  signal cancelled

  color: Config.appearance.color.scrim
  onEffectiveRegionsChanged: area.checkForRegionHint()

  ShinyRectangle {
    color: Colors.transparentize("white", 0.75)
    x: Math.min(area.userSelectionStartX, area.userSelectionEndX)
    y: Math.min(area.userSelectionStartY, area.userSelectionEndY)
    width: Math.abs(area.userSelectionEndX - area.userSelectionStartX)
    height: Math.abs(area.userSelectionEndY - area.userSelectionStartY)
    opacity: !root.selectionMade && area.isHolding ? 1 : 0
    border.color: Config.appearance.color.primary
    border.width: 2

    Behavior on opacity {
      EffectNumberAnimation {}
    }
  }

  Repeater {
    model: root.effectiveRegions
    delegate: ShinyRectangle {
      required property RectangularRegion modelData

      color: Colors.transparentize("white", 0.85)
      x: modelData.x - border.width
      y: modelData.y - border.width
      width: modelData.width + border.width * 2
      height: modelData.height + border.width * 2
      opacity: !root.selectionMade && !area.isHolding && area.hoveredRegion === modelData ? 1 : 0
      border.color: Config.appearance.color.secondary
      border.width: 2
      radius: modelData.source === "window" ? root.hyprlandRounding : 0

      Behavior on opacity {
        EffectNumberAnimation {}
      }
    }
  }

  Loader {
    anchors.fill: parent
    active: root.freeze
    sourceComponent: ScreencopyView {
      anchors.fill: parent
      live: false
      paintCursor: false
      captureSource: root.screen
    }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    cursorShape: Qt.CrossCursor
    hoverEnabled: true
    focus: true

    property bool isHolding: false
    property real userSelectionStartX: 0
    property real userSelectionStartY: 0
    property real userSelectionEndX: 0
    property real userSelectionEndY: 0
    property RectangularRegion hoveredRegion: null

    Keys.onEscapePressed: root.cancelled()

    onPressed: {
      holdTimer.restart();
      userSelectionStartX = mouseX;
      userSelectionStartY = mouseY;
      userSelectionEndX = mouseX;
      userSelectionEndY = mouseY;
    }

    onReleased: {
      holdTimer.stop();

      if (isHolding) {
        root.selected(regionComponent.createObject(root, {
          source: "user",
          screen: root.screen,
          x: Math.min(userSelectionStartX, userSelectionEndX),
          y: Math.min(userSelectionStartY, userSelectionEndY),
          width: Math.abs(userSelectionEndX - userSelectionStartX),
          height: Math.abs(userSelectionEndY - userSelectionStartY)
        }));

        root.selectionMade = true;
        isHolding = false;
      } else if (hoveredRegion !== null) {
        root.selected(hoveredRegion);
        root.selectionMade = true;
      }
    }

    onPositionChanged: {
      checkForRegionHint();

      if (pressed && !isHolding) {
        if (Math.abs(mouseX - userSelectionStartX) > root.pressAndHoldThreshold || Math.abs(mouseY - userSelectionStartY) > root.pressAndHoldThreshold) {
          holdTimer.stop();
          isHolding = true;
        }
      }

      if (isHolding) {
        userSelectionEndX = mouseX;
        userSelectionEndY = mouseY;
      }
    }

    function checkForRegionHint() {
      for (const region of root.effectiveRegions) {
        if (region.contains(mouseX, mouseY)) {
          hoveredRegion = region;
          return;
        }
      }

      hoveredRegion = null;
    }

    Timer {
      id: holdTimer
      interval: 500
      onTriggered: area.isHolding = true
    }
  }

  Component {
    id: regionComponent
    RectangularRegion {}
  }
}
