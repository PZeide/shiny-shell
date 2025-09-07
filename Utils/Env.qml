pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

QtObject {
  readonly property bool isDev: Quickshell.env("QS_ENVIRONMENT") === "dev"
}
