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
    property list<string> parts: ["h a", "AP", "mm"]
    property bool showApKanji: true
  }

  component WorkspacesConfig: JsonObject {
    property bool showKanji: true
  }
}
