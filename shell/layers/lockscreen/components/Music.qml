pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.components
import qs.components.controls
import qs.config
import qs.services
import qs.utils
import qs.utils.animations

ShinyRectangle {
  id: root

  required property MprisPlayer player
  readonly property bool hasTrack: player !== null && player.playbackState !== MprisPlaybackState.Stopped

  implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin
  color: Config.appearance.color.surface
  radius: Config.appearance.rounding.md

  RowLayout {
    id: layout
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.margins: Config.appearance.padding.lg
    spacing: Config.appearance.padding.lg

    ShinyClippingRectangle {
      id: musicArt
      Layout.fillHeight: true
      Layout.preferredWidth: height
      radius: Config.appearance.rounding.sm

      Image {
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        retainWhileLoading: true
        sourceSize.width: musicArt.width
        sourceSize.height: musicArt.height
        source: !root.hasTrack || root.player.trackArtUrl === "" ? Player.placeholderTrackArt : root.player.trackArtUrl
      }

      Loader {
        active: root.hasTrack
        anchors.fill: parent

        sourceComponent: ShinyInteractiveLayer {
          id: playPauseArea
          layerColor: Config.appearance.color.surfaceContainerLowest
          hoverOpacity: 0.5
          clickOpacity: 0.6

          onContainsMouseChanged: playPauseIcon.opacity = containsMouse ? 1 : 0
          onPressed: root.player.togglePlaying()

          ShinyIcon {
            id: playPauseIcon
            icon: root.player.playbackState === MprisPlaybackState.Playing ? "pause" : "play_arrow"
            font.pointSize: Config.appearance.font.size.xxl
            anchors.centerIn: parent
            opacity: 0
            fill: 1

            Behavior on opacity {
              EffectNumberAnimation {}
            }
          }
        }
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      ShinyAnimatedText {
        Layout.maximumWidth: durationSlider.implicitWidth
        text: root.hasTrack ? (root.player.trackTitle || "Unknown Title") : "No Track"
        font.pointSize: Config.appearance.font.size.md
        font.weight: Font.Medium
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
      }

      ShinyAnimatedText {
        Layout.maximumWidth: durationSlider.implicitWidth
        text: root.hasTrack ? (root.player.trackArtist || "Unknown Artist") : ""
        font.pointSize: Config.appearance.font.size.sm
        font.weight: Font.Light
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
      }

      Item {
        Layout.fillHeight: true
      }

      ShinySubtleSlider {
        id: durationSlider

        property bool positionSupported: root.hasTrack && root.player.lengthSupported && root.player.positionSupported
        property bool moveSupported: root.hasTrack && root.player.canSeek && root.player.positionSupported

        enabled: positionSupported && moveSupported
        implicitTrackWidth: 240
        cooperativeValue: positionSupported ? root.player.position / root.player.length : 1
        showTooltip: positionSupported
        tooltipText: positionSupported ? `${Formatting.numericDuration(value * root.player.length)} / ${Formatting.numericDuration(root.player.length)}` : ""

        onMoved: {
          if (moveSupported) {
            root.player.position = value * root.player.length;
          }
        }
      }
    }
  }
}
