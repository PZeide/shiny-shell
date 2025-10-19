pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.components
import qs.config
import qs.services
import qs.utils
import qs.utils.animations

ShinyRectangle {
  id: root

  readonly property bool showMusic: Player.preferred !== null && Player.preferred.playbackState != MprisPlaybackState.Stopped

  implicitWidth: root.showMusic ? 424 : 50
  implicitHeight: 132
  color: Config.appearance.color.bgPrimary
  topLeftRadius: Config.appearance.rounding.lg

  Loader {
    active: root.showMusic
    anchors.fill: parent
    anchors.leftMargin: 12
    anchors.rightMargin: 12

    sourceComponent: Item {
      anchors.fill: parent

      RowLayout {
        id: musicContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ShinyClippingRectangle {
          id: musicArt
          implicitWidth: 96
          implicitHeight: 96
          radius: Config.appearance.rounding.sm

          Image {
            anchors.fill: parent
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            retainWhileLoading: true
            sourceSize.width: 96
            sourceSize.height: 96
            source: Player.preferred.trackArtUrl === "" ? Player.placeholderTrackArt : Player.preferred.trackArtUrl
          }
        }

        ColumnLayout {
          Layout.alignment: Qt.AlignLeft | Qt.AlignTop
          Layout.fillWidth: true
          spacing: 0

          ShinyText {
            Layout.fillWidth: true
            animateTextChange: true
            text: Player.preferred.trackTitle || "Unknown Title"
            font.pointSize: Config.appearance.font.size.lg
            font.weight: Font.Medium
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
          }

          ShinyText {
            Layout.fillWidth: true
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
            Layout.fillWidth: true

            ShinyRectangle {
              implicitWidth: 32
              implicitHeight: 32
              radius: Config.appearance.rounding.full
              color: Config.appearance.color.bgSecondary

              ShinyIcon {
                anchors.centerIn: parent
                icon: "music_note"
                fill: 1
                font.pointSize: Config.appearance.font.size.lg
              }
            }

            Timer {
              running: Player.preferred.playbackState == MprisPlaybackState.Playing
              interval: 1000
              repeat: true
              onTriggered: Player.preferred.positionChanged()
            }

            ShinySlider {
              property bool positionSupported: Player.preferred.lengthSupported && Player.preferred.positionSupported

              Layout.fillWidth: true
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
  }

  ShinyIcon {
    id: musicOff
    anchors.centerIn: parent
    visible: !root.showMusic
    icon: "music_off"
    font.weight: Font.DemiBold
    font.pointSize: Config.appearance.font.size.xl
  }

  Behavior on implicitWidth {
    EffectNumberAnimation {}
  }
}
