pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

JsonObject {
  property list<string> blacklist: []
  property list<string> preferred: ["cider"]
}
