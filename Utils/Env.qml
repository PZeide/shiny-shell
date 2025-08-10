pragma Singleton

import Quickshell

Singleton {
  readonly property bool isDev: Quickshell.env("QS_ENVIRONMENT") === "dev"
}
