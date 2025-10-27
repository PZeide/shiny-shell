pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.services
import qs.utils.animations
import qs.layers.lockscreen.components
import qs.layers.wallpaper
import qs.layers.corner

WlSessionLockSurface {
  id: root

  required property WlSessionLock sessionLock
  required property LockContext context

  readonly property bool unlocking: context.state === "animateOut" || context.state === "fadeOut"
  readonly property int errorDuration: 5000
  property int error: PamResult.Success

  color: "transparent"

  MouseArea {
    anchors.fill: parent
    enabled: false
    cursorShape: Qt.BlankCursor
  }

  WallpaperImage {
    id: background
    source: Config.wallpaper.path
    opacity: root.context.opacityFactor

    layer.effect: MultiEffect {
      autoPaddingEnabled: false
      blurEnabled: true
      blur: 0.65 * root.context.readinessFactor
      blurMax: 48
    }
  }

  Barcode {
    anchors.centerIn: parent
    passwordBuffer: input.text
    // use readinessFactor to make it fade before the foreground
    opacity: root.context.readinessFactor
  }

  Loader {
    active: Config.wallpaper.foreground && Foreground.isAvailable
    anchors.fill: parent

    sourceComponent: WallpaperImage {
      id: foreground
      source: Foreground.path
      opacity: root.context.opacityFactor
    }
  }

  RowLayout {
    id: bottomRectangle
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottomMargin: -bottomRectangle.implicitHeight * (1 - root.context.readinessFactor)
    spacing: 0

    BottomClock {
      id: bottomClock
      Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
    }

    BottomBar {
      id: bottomBar
      Layout.alignment: Qt.AlignBottom
      Layout.fillWidth: true
      leftOffset: bottomClock.width
      rightOffset: bottomMusic.width
    }

    BottomMusic {
      id: bottomMusic
      Layout.alignment: Qt.AlignBottom | Qt.AlignRight
    }
  }

  LockIndicator {
    id: lockIndicator

    property real errorTopMargin: root.error === PamResult.Success ? -errorHeight : 0

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: errorTopMargin - lockHeight * (1 - root.context.readinessFactor)
    processing: root.unlocking || pam.active
    error: root.error

    Behavior on errorTopMargin {
      EffectNumberAnimation {}
    }
  }

  RoundedCorner {
    anchors.top: parent.top
    anchors.left: parent.left
    type: RoundedCorner.Type.TopLeft
  }

  RoundedCorner {
    anchors.top: parent.top
    anchors.right: parent.right
    type: RoundedCorner.Type.TopRight
  }

  GhostPasswordInput {
    id: input
    readOnly: pam.active || root.unlocking

    onAccepted: {
      if (pam.active)
        return;

      pam.start();
    }
  }

  PamContext {
    id: pam

    onCompleted: result => {
      if (result === PamResult.Success) {
        root.error = PamResult.Success;
        root.context.unlock();
      } else {
        root.error = result;
        resetError.restart();
        input.clear();
      }
    }

    onResponseRequiredChanged: {
      if (!responseRequired)
        return;

      respond(input.text);
    }
  }

  Timer {
    id: resetError
    interval: root.errorDuration
    onTriggered: root.error = PamResult.Success
  }
}
