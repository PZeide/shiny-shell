pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import qs.components
import qs.components.controls
import qs.config
import qs.utils

ShinyRectangle {
  id: root

  required property AuthFlow flow
  property bool enabled: flow !== null && flow.isResponseRequired
  property string cachedMessage: ""

  onFlowChanged: {
    if (flow) {
      cachedMessage = flow.message;
    }
  }

  anchors.centerIn: parent
  color: Config.appearance.color.surfaceContainerLow
  radius: Config.appearance.rounding.md
  border.width: 1
  border.color: Colors.transparentize(Config.appearance.color.outline, 0.5)

  implicitWidth: layout.implicitWidth + Config.appearance.padding.xl * 2
  implicitHeight: layout.implicitHeight + Config.appearance.padding.xl * 2

  function focusField() {
    field.forceActiveFocus();
  }

  ColumnLayout {
    id: layout
    anchors.centerIn: parent
    implicitWidth: Math.min(childrenRect.width, 450)
    spacing: Config.appearance.spacing.lg

    ShinyText {
      text: "Authentication Required"
      font.pointSize: Config.appearance.font.size.lg
      font.weight: Font.Medium
    }

    ShinyText {
      Layout.maximumWidth: layout.width
      text: root.cachedMessage
      font.pointSize: Config.appearance.font.size.sm
      font.weight: Font.Light
      wrapMode: Text.WordWrap
    }

    ShinyRectangle {
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: layout.width * 0.9
      implicitHeight: 1
      color: Colors.transparentize(Config.appearance.color.outline, 0.5)
    }

    ColumnLayout {
      Layout.alignment: Qt.AlignHCenter
      Layout.maximumWidth: layout.width * 0.6

      ShinyTextField {
        id: field
        Layout.fillWidth: true
        enabled: root.enabled
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        sIcon.name: "lock"
        placeholderText: "Password"

        onAccepted: root.flow.submit(text)
      }

      ShinyAnimatedText {
        text: (root.enabled && root.flow.failed) ? "Authentication failed" : ""
        color: Config.appearance.color.error
        font.pointSize: Config.appearance.font.size.sm
        font.weight: Font.Light
        animationDistanceY: -6
      }
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignRight
      spacing: Config.appearance.spacing.sm

      ShinyButton {
        enabled: root.enabled
        variant: ShinyButton.Variant.Secondary
        text: "Cancel"

        onClicked: root.flow.cancelAuthenticationRequest()
      }

      ShinyButton {
        enabled: root.enabled
        variant: ShinyButton.Variant.Primary
        text: "Authenticate"
        sIcon.name: "vpn_key"

        onClicked: root.flow.submit(field.text)
      }
    }
  }
}
