pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt.labs.synchronizer
import Shiny.Greeter
import qs.components
import qs.components.controls
import qs.config
import qs.services

ShinyRectangle {
  id: root

  required property bool acceptAuthentication
  required property SessionDesktopEntry session
  property string password

  implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
  implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

  signal authenticationRequested

  function focusField() {
    field.forceActiveFocus();
  }

  ColumnLayout {
    id: layout
    anchors.centerIn: parent
    anchors.margins: Config.appearance.padding.lg
    spacing: Config.appearance.padding.lg

    RowLayout {
      Layout.fillWidth: true
      spacing: 4

      ShinyText {
        text: "Welcome"
        font.pointSize: Config.appearance.font.size.lg
        font.weight: Font.Light
      }

      ShinyText {
        text: Config.session.username
        font.pointSize: Config.appearance.font.size.lg
        color: Config.appearance.color.primary
        font.weight: Font.Medium
      }

      Item {
        Layout.fillWidth: true
      }

      ShinyRectangle {
        Layout.preferredWidth: sessionText.implicitWidth + Config.appearance.padding.xs * 2
        Layout.preferredHeight: sessionText.implicitHeight + Config.appearance.padding.xxs * 2
        visible: root.session !== null
        color: Config.appearance.color.surfaceContainer
        radius: Config.appearance.rounding.xxs

        ShinyText {
          id: sessionText
          anchors.centerIn: parent
          color: Config.appearance.color.overSurface
          font.weight: Font.Light

          text: {
            if (root.session === null) {
              return "";
            } else if (root.session.desktopName !== "") {
              return root.session.desktopName;
            } else {
              return root.session.name;
            }
          }
        }
      }

      ShinyText {
        text: Host.osIcon
        font.family: Config.appearance.font.family.iconNerd
        color: Config.appearance.color.primary
      }
    }

    RowLayout {
      Layout.preferredHeight: 55
      spacing: Config.appearance.padding.lg

      ShinyClippingRectangle {
        id: faceImage
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.height
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
        enabled: root.acceptAuthentication
        font.pointSize: Config.appearance.font.size.md
        sIcon.name: "lock"
        sIcon.grade: 1000
        sIconFont.pointSize: Config.appearance.font.size.lg
        placeholderText: "Enter password"
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

        onAccepted: root.authenticationRequested()

        Synchronizer on text {
          property alias source: root.password
        }
      }
    }

    ShinyButton {
      Layout.fillWidth: true
      Layout.preferredHeight: 35
      enabled: root.acceptAuthentication
      variant: ShinyButton.Variant.Secondary
      text: "Press enter to authenticate"
    }
  }
}
