pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.services.models

Singleton {
  id: root

  readonly property var monitors: Hyprland.monitors
  readonly property var workspaces: Hyprland.workspaces
  readonly property var toplevels: Hyprland.toplevels
  property var layers: []
  property var options: []

  readonly property HyprlandMonitor activeMonitor: Hyprland.focusedMonitor
  readonly property HyprlandWorkspace activeWorkspace: Hyprland.focusedWorkspace
  readonly property HyprlandToplevel activeToplevel: Hyprland.activeToplevel

  function dispatch(request: string) {
    Hyprland.dispatch(request);
  }

  function monitorFor(screen: ShellScreen): HyprlandMonitor {
    return Hyprland.monitorFor(screen);
  }

  function toShellScreen(monitor: HyprlandMonitor): ShellScreen {
    return Quickshell.screens.find(s => s.name === monitor.name);
  }

  function optionValueFor(key: string): var {
    return root.options.find(o => o.value === key)?.data?.current ?? null;
  }

  function refreshMonitors() {
    Hyprland.refreshMonitors();
  }

  function refreshWorkspaces() {
    Hyprland.refreshWorkspaces();
  }

  function refreshToplevels() {
    Hyprland.refreshToplevels();
  }

  function refreshLayers() {
    layersProcess.exec({});
  }

  function refreshOptions() {
    optionsProcess.exec({});
  }

  Process {
    id: layersProcess
    command: ["hyprctl", "layers", "-j"]
    stdout: StdioCollector {
      id: layersCollector
      onStreamFinished: {
        const data = JSON.parse(layersCollector.text);
        const layers = [];

        for (const monitorName of Object.keys(data)) {
          const monitor = root.monitors.values.find(m => m.name === monitorName);
          if (!monitor) {
            console.warn(`Monitor ${monitorName} not found for layers`);
            continue;
          }

          const levels = data[monitorName].levels;
          for (const levelKey in levels) {
            const rawLayers = levels[levelKey];

            for (const rawLayer of rawLayers) {
              layers.push(layerComponent.createObject(null, {
                namespace: rawLayer.namespace,
                monitor: monitor,
                level: parseInt(levelKey),
                x: rawLayer.x,
                y: rawLayer.y,
                width: rawLayer.w,
                height: rawLayer.h,
                lastIpcObject: rawLayer
              }));
            }
          }
        }

        root.layers = layers;
      }
    }
  }

  Process {
    id: optionsProcess
    command: ["hyprctl", "descriptions", "-j"]
    stdout: StdioCollector {
      id: optionsCollector
      onStreamFinished: {
        root.options = JSON.parse(optionsCollector.text);
      }
    }
  }

  Component {
    id: layerComponent
    HyprlandLayer {}
  }

  Connections {
    target: Hyprland

    function onRawEvent(event: HyprlandEvent) {
      const n = event.name;
      if (n.endsWith("v2"))
        return;

      switch (n) {
      // --- Toplevels AND Workspaces ---
      // These events change both the window state AND the structural layout
      // or client count of the workspace(s) they reside in.
      case "openwindow":
      case "closewindow":
      case "kill":
      case "movewindow":
        root.refreshToplevels();
        root.refreshWorkspaces();
        break;

      /// --- Toplevels ONLY ---
      // These events only change the metadata or visual state of a specific window.
      case "activewindow":
      case "fullscreen":
      case "changefloatingmode":
      case "pin":
      case "togglegroup":
      case "moveintogroup":
      case "moveoutofgroup":
      case "windowtitle":
      case "urgent":
      case "minimized":
        root.refreshToplevels();
        break;

      // --- Workspaces AND Monitors ---
      // Monitor connects/disconnects shift workspaces around.
      // Moving a workspace directly affects the monitor's state as well.
      case "workspace":
      case "focusedmon":
      case "activespecial":
      case "monitoradded":
      case "monitorremoved":
      case "moveworkspace":
        root.refreshMonitors();
        root.refreshWorkspaces();
        break;

      // --- Workspaces ONLY ---
      // Structural changes to workspaces that don't directly change monitor
      // count or individual window states.
      case "createworkspace":
      case "destroyworkspace":
      case "renameworkspace":
        root.refreshWorkspaces();
        break;

      // --- Config / Options ---
      case "configreloaded":
        root.refreshOptions();
        break;

      // --- Layers ---
      case "openlayer":
      case "closelayer":
        root.refreshLayers();
        break;
      }
    }
  }

  Component.onCompleted: {
    root.refreshLayers();
    root.refreshOptions();
  }
}
