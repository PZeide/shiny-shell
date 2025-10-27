pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.components
import qs.config
import qs.services
import qs.utils
import qs.utils.animations
import qs.layers.corner

ShinyRectangle {
  id: root

  readonly property bool showMusic: Player.preferred !== null && Player.preferred.playbackState != MprisPlaybackState.Stopped

  implicitWidth: root.showMusic ? loader.implicitWidth : musicOff.implicitWidth + Config.appearance.padding.lg * 2
  height: 120
  color: Config.appearance.color.surface
  topLeftRadius: Config.appearance.rounding.lg

  Behavior on implicitWidth {
    EffectNumberAnimation {}
  }

  Loader {
    id: loader
    active: root.showMusic

    sourceComponent: RowLayout {
      id: musicContent
      height: root.height
      spacing: Config.appearance.spacing.md

      ShinyClippingRectangle {
        id: musicArt
        Layout.leftMargin: Config.appearance.spacing.md
        implicitWidth: 100
        implicitHeight: 100
        radius: Config.appearance.rounding.sm

        Image {
          anchors.fill: parent
          asynchronous: true
          fillMode: Image.PreserveAspectCrop
          retainWhileLoading: true
          sourceSize.width: 100
          sourceSize.height: 100
          source: Player.preferred.trackArtUrl === "" ? Player.placeholderTrackArt : Player.preferred.trackArtUrl
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        Layout.rightMargin: Config.appearance.spacing.md
        Layout.topMargin: Config.appearance.spacing.lg
        Layout.bottomMargin: Config.appearance.spacing.lg
        spacing: 0

        ShinyText {
          Layout.maximumWidth: positionRow.implicitWidth
          animateTextChange: true
          text: Player.preferred.trackTitle || "Unknown Title"
          font.pointSize: Config.appearance.font.size.lg
          font.weight: Font.Medium
          elide: Text.ElideRight
          wrapMode: Text.NoWrap
        }

        ShinyText {
          Layout.maximumWidth: positionRow.implicitWidth
          animateTextChange: true
          text: Player.preferred.trackArtist || "Unknown Artist"
          font.pointSize: Config.appearance.font.size.md
          font.weight: Font.Light
          elide: Text.ElideRight
          wrapMode: Text.NoWrap
        }

        Item {
          Layout.fillHeight: true
        }

        RowLayout {
          id: positionRow

          ShinyRectangle {
            implicitWidth: 32
            implicitHeight: 32
            radius: Config.appearance.rounding.full
            color: Config.appearance.color.surfaceContainer

            ShinyIcon {
              anchors.centerIn: parent
              icon: "music_note"
              fill: 1
              font.pointSize: Config.appearance.font.size.lg
            }
          }

          ShinySlider {
            property bool positionSupported: Player.preferred.lengthSupported && Player.preferred.positionSupported

            enabled: false
            implicitWidth: 190
            implicitHeight: 10
            value: positionSupported ? Player.preferred.position / Player.preferred.length : 1
          }

          ShinyText {
            visible: Player.preferred.positionSupported
            text: Player.preferred.lengthSupported ? `${Formatting.numericDuration(Player.preferred.position)} / ${Formatting.numericDuration(Player.preferred.length)}` : Formatting.numericDuration(Player.preferred.position)
            font.pointSize: Config.appearance.font.size.sm
          }
        }
      }
    }
  }

  ShinyIcon {
    id: musicOff
    anchors.centerIn: parent
    visible: !root.showMusic
    icon: "music_off"
    font.weight: Font.DemiBold
    font.pointSize: Config.appearance.font.size.xl
  }

  RoundedCorner {
    anchors.bottom: parent.top
    anchors.right: parent.right
    type: RoundedCorner.Type.BottomRight
  }
}
