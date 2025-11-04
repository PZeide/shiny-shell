pragma ComponentBehavior: Bound

import Quickshell.Io

JsonObject {
  property int height: 34
  property list<string> leftModules: ["host", "clock", "weather"]
  property list<string> centerModules: ["workspaces"]
  property list<string> rightModules: ["battery"]
  property WorkspacesConfig workspaces: WorkspacesConfig {}

  component WorkspacesConfig: JsonObject {
    property int count: 0
  }
}
