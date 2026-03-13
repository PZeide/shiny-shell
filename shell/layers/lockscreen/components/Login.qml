pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.components.controls
import qs.config

ShinyRectangle {
  id: root

  required property bool fieldEnabled

  implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

  signal loginRequested(password: string)

  function reset() {
    field.text = "";
  }

  function focusField() {
    field.forceActiveFocus();
  }

  RowLayout {
    id: layout
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.margins: Config.appearance.padding.lg
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    spacing: Config.appearance.padding.lg

    ShinyClippingRectangle {
      id: faceImage
      Layout.preferredHeight: layout.height
      Layout.preferredWidth: layout.height
      radius: Config.appearance.rounding.sm

      Image {
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        retainWhileLoading: true
        sourceSize.width: faceImage.width
        sourceSize.height: faceImage.height
        source: Config.session.facePath
      }
    }

    ShinyTextField {
      id: field
      Layout.fillHeight: true
      implicitWidth: 240
      enabled: root.fieldEnabled
      iconName: "lock"
      placeholderText: "Enter password"
      echoMode: TextInput.Password
      inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

      onAccepted: root.loginRequested(text)
    }
  }
}
