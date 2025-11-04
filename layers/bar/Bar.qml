pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.containers
import qs.config
import qs.layers.bar.modules
import qs.services

Variants {
  model: Quickshell.screens

  ShinyWindow {
    id: root

    required property ShellScreen modelData

    readonly property int moduleSpacing: Config.appearance.spacing.sm

    name: "bar"
    screen: modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Config.bar.height
    color: Config.appearance.color.surface
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Row {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.leftMargin: Config.appearance.spacing.sm
      spacing: root.moduleSpacing

      Repeater {
        model: Config.bar.leftModules
        delegate: delegateChooser
      }
    }

    Row {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: root.moduleSpacing

      Repeater {
        model: Config.bar.centerModules
        delegate: delegateChooser
      }
    }

    Row {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.rightMargin: Config.appearance.spacing.sm
      spacing: root.moduleSpacing

      Repeater {
        model: Config.bar.rightModules
        delegate: delegateChooser
      }
    }

    DelegateChooser {
      id: delegateChooser

      DelegateChoice {
        roleValue: "battery"
        delegate: DelegateLoader {
          active: Battery.isAvailable
          sourceComponent: BatteryModule {}
        }
      }

      DelegateChoice {
        roleValue: "clock"
        delegate: ClockModule {}
      }

      DelegateChoice {
        roleValue: "host"
        delegate: HostModule {}
      }

      DelegateChoice {
        roleValue: "location"
        delegate: DelegateLoader {
          active: Location.isAvailable
          sourceComponent: LocationModule {}
        }
      }

      DelegateChoice {
        roleValue: "weather"
        delegate: DelegateLoader {
          active: Weather.isAvailable
          sourceComponent: WeatherModule {}
        }
      }

      DelegateChoice {
        roleValue: "workspaces"
        delegate: WorkspacesModule {
          screen: root.screen
        }
      }
    }
  }

  component DelegateLoader: Loader {
    anchors.top: parent.top
    anchors.bottom: parent.bottom
  }
}
