pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland

QtObject {
  required property var lastIpcObject
  required property HyprlandMonitor monitor
  required property list<HyprlandToplevel> toplevels

  readonly property string address: String(lastIpcObject.address ?? lastIpcObject.id ?? lastIpcObject.name)
  readonly property string name: lastIpcObject.name ?? ""

  readonly property string type: {
    const ipcType = lastIpcObject.type;
    if (ipcType === "special" || name.startsWith("special:")) {
      return "special";
    }

    if (ipcType === "numbered" || ipcType === "named") {
      return ipcType;
    }

    return Number(lastIpcObject.id ?? address) > 0 ? "numbered" : "named";
  }

  readonly property int number: type === "numbered" ? Number(lastIpcObject.id ?? address) : -1
  readonly property int windows: lastIpcObject.windows ?? 0
  readonly property bool hasFullscreen: lastIpcObject.hasfullscreen ?? false
  readonly property bool persistent: lastIpcObject.ispersistent ?? false
  readonly property bool active: monitor !== null && name === monitor.lastIpcObject.activeWorkspace?.name

  function activate() {
    const selector = type === "special" ? name.replace(/^special:/, "") : type === "numbered" ? String(number) : "name:" + name;
    const argument = '"' + selector.replace(/[\\"\x00-\x1f\x7f]/g, character => "\\" + String(character.charCodeAt(0)).padStart(3, "0")) + '"';
    Hyprland.dispatch(type === "special" ? "hl.dsp.workspace.toggle_special(" + argument + ")" : "hl.dsp.focus({ workspace = " + argument + " })");
  }
}
