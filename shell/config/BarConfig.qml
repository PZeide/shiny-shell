pragma ComponentBehavior: Bound

import Quickshell.Io

JsonObject {
  property int size: 42
  property list<string> topModules: ["workspaces", "tray"]
  property list<string> centerModules: ["clock"]
  property list<string> bottomModules: ["screen-recorder"]

  property ClockConfig clock: ClockConfig {}
  property WorkspacesConfig workspaces: WorkspacesConfig {}

  component ClockConfig: JsonObject {
    property list<string> parts: ["h a", "mm", "AP"]
  }

  component WorkspacesConfig: JsonObject {
    property int count: 0
  }
}
