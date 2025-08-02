pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.Config

Item {
  id: root

  required property string passwordBuffer
  readonly property string availableChars: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  property string barcodeBuffer: ""

  implicitHeight: barcodeText.contentHeight
  implicitWidth: barcodeText.contentWidth
  anchors.centerIn: parent
  clip: true

  Rectangle {
    id: gradient

    anchors.fill: barcodeText
    visible: false

    gradient: Gradient {
      GradientStop {
        color: Config.appearance.color.basePrimary
        position: 0.0
      }

      GradientStop {
        color: Config.appearance.color.accentPrimary
        position: 1.0
      }
    }
  }

  Text {
    id: barcodeText

    anchors.centerIn: parent
    visible: false
    font.bold: true
    font.family: "Libre Barcode 128"
    font.pointSize: 400
    layer.enabled: true
    renderType: Text.NativeRendering
    text: root.barcodeBuffer
  }

  MultiEffect {
    anchors.fill: gradient
    maskEnabled: true
    maskSource: barcodeText
    maskSpreadAtMin: 1.0
    maskThresholdMax: 1.0
    maskThresholdMin: 0.5
    source: gradient
  }

  onPasswordBufferChanged: {
    const currentBarcodeLength = barcodeBuffer.length;
    const newPasswordLength = passwordBuffer.length;

    if (newPasswordLength > currentBarcodeLength) {
      const charsToAdd = newPasswordLength - currentBarcodeLength;
      let newChars = "";
      for (let i = 0; i < charsToAdd; i++) {
        const randomIndex = Math.floor(Math.random() * availableChars.length);
        newChars += availableChars.charAt(randomIndex);
      }

      barcodeBuffer += newChars;
    } else if (newPasswordLength < currentBarcodeLength) {
      const charsToRemove = currentBarcodeLength - newPasswordLength;
      barcodeBuffer = barcodeBuffer.substring(0, barcodeBuffer.length - charsToRemove);
    }
  }
}
