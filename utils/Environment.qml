pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
  readonly property bool isDev: Quickshell.env("QS_ENVIRONMENT") === "dev"
}
