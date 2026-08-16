pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

JsonObject {
  property bool enabled: true
  property AnnotatorConfig annotator: AnnotatorConfig {}

  component AnnotatorConfig: JsonObject {
    property string outputFilename: (Quickshell.env("XDG_PICTURES_DIR") ?? (Quickshell.env("HOME") + "/Pictures")) + "/Screenshot-%Y-%m-%d_%H-%M-%S.png"
    property string initialTool: "pointer"
    property list<string> earlyExit: ["all"]
    property real annotationSizeFactor: 1
    property list<string> actionsOnEnter: ["save-to-file-as"]
    property list<string> actionsOnEscape: ["save-to-clipboard"]
    property list<string> actionsOnRightClick: []
  }
}
