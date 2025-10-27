pragma ComponentBehavior: Bound

import Quickshell.Io

JsonObject {
  property int height: 34
  property WorkspacesConfig workspaces: WorkspacesConfig {}

  component WorkspacesConfig: JsonObject {
    property int count: 0
  }
}
