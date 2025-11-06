pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ShinyRectangle {
  id: root

  implicitWidth: layout.implicitWidth + Config.appearance.padding.sm * 2
  implicitHeight: layout.implicitHeight + Config.appearance.padding.sm * 2
  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

  signal shouldClose

  ColumnLayout {
    id: layout
    anchors.centerIn: parent
    spacing: Config.appearance.spacing.sm

    SessionButton {
      id: sessionShutdown
      icon: "mode_off_on"
      name: "Shutdown"
      focus: true
      KeyNavigation.down: !mouseFocused ? sessionReboot : null

      onInvoked: {
        Session.shutdown();
        root.shouldClose();
      }
    }

    SessionButton {
      id: sessionReboot
      icon: "restart_alt"
      name: "Reboot"
      KeyNavigation.up: !mouseFocused ? sessionShutdown : null
      KeyNavigation.down: !mouseFocused ? sessionSuspend : null

      onInvoked: {
        Session.reboot();
        root.shouldClose();
      }
    }

    SessionButton {
      id: sessionSuspend
      icon: "bedtime"
      name: "Suspend"
      KeyNavigation.up: !mouseFocused ? sessionReboot : null
      KeyNavigation.down: !mouseFocused ? sessionLock : null

      onInvoked: {
        Session.suspend();
        root.shouldClose();
      }
    }

    SessionButton {
      id: sessionLock
      icon: "lock"
      name: "Lock"
      KeyNavigation.up: !mouseFocused ? sessionSuspend : null

      onInvoked: {
        Session.lock();
        root.shouldClose();
      }
    }
  }
}
