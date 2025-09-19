pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.widgets
import qs.config
import qs.layers.launcher.models
import qs.layers.launcher.plugins

Item {
  id: root

  required property ShellScreen screen
  property bool opened: false

  readonly property LauncherPlugin defaultPlugin: ApplicationsPlugin
  readonly property var availablePlugins: ({
      "calculator": CalculatorPlugin
    })
  property LauncherPlugin activePlugin: defaultPlugin
  property var extraPlugins: {
    const activePlugins = [];

    for (const pluginName of Config.launcher.plugins) {
      const plugin = availablePlugins[pluginName];
      if (!plugin) {
        console.warn(`Missing launcher plugin ${pluginName}`);
        continue;
      }

      activePlugins.push(plugin);
    }

    return activePlugins;
  }

  property int selectedItemIndex
  property list<LauncherItemDescriptor> shownItems: []

  function filter(input: string) {
    selectedItemIndex = 0;

    for (const candidatePlugin of extraPlugins) {
      if (input.startsWith(candidatePlugin.prefix)) {
        activePlugin = candidatePlugin;
        shownItems = candidatePlugin.filter(input);
        return;
      }
    }

    activePlugin = defaultPlugin;
    shownItems = defaultPlugin.filter(input);
  }

  LazyLoader {
    activeAsync: root.opened

    ShinyWindow {
      id: window

      name: "launcher"
      screen: root.screen
      anchors.bottom: true
      margins.bottom: 8
      implicitWidth: container.implicitWidth
      implicitHeight: container.implicitHeight
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      onVisibleChanged: {
        if (visible) {
          grab.active = true;
          searchField.focus = true;
        }
      }

      Component.onCompleted: {
        // Initial filtering
        root.filter("");
      }

      HyprlandFocusGrab {
        id: grab
        windows: [window]
      }

      Connections {
        target: grab
        function onActiveChanged() {
          if (!grab.active)
            root.opened = false;
        }
      }

      ShinyRectangle {
        id: container

        implicitWidth: root.screen.width * 0.35
        implicitHeight: itemsLayout.implicitHeight + searchField.implicitHeight + searchField.anchors.margins * 2
        color: Config.appearance.color.bgPrimary
        radius: Config.appearance.rounding.md

        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) {
            event.accepted = true;
            root.opened = false;
          }
        }

        ColumnLayout {
          id: itemsLayout
        }

        ShinyTextField {
          id: searchField

          anchors.bottom: parent.bottom
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 8
          placeholderText: "Search..."
          icon: "search"

          onTextChanged: {
            root.filter(text);
          }
        }
      }
    }
  }

  IpcHandler {
    target: "launcher"

    function toggle() {
      console.info("Received launcher toggle from IPC");
      root.opened = !root.opened;
    }

    function open() {
      console.info("Received launcher open from IPC");
      root.opened = true;
    }

    function close() {
      console.info("Received launcher close from IPC");
      root.opened = false;
    }
  }
}
