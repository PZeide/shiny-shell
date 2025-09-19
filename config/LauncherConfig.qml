pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property list<string> plugins: ["calculator", "websearch"]
  property int maxItems: 6
  property bool showActions: false
}
