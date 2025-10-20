pragma ComponentBehavior: Bound

import Quickshell.Io

JsonObject {
  property bool enabled: true
  property int height: 34
  property int moduleSpacing: 6
  property WorkspacesConfig workspaces: WorkspacesConfig {}

  component WorkspacesConfig: JsonObject {
    property int count: 0
    property int spacing: 6
    property int size: 12
  }
}
