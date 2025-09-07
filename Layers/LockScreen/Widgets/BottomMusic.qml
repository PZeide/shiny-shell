pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.Widgets
import qs.Config
import qs.Services

ShinyRectangle {
  id: root

  readonly property bool showMusic: Player.preferred !== null && Player.preferred.playbackState != MprisPlaybackState.Stopped
  readonly property real musicLoaderFullWidth: musicLoader.implicitWidth + musicLoader.anchors.leftMargin + musicLoader.anchors.rightMargin

  implicitWidth: root.showMusic ? musicLoaderFullWidth : 50
  implicitHeight: 142
  color: Config.appearance.color.bgPrimary
  topLeftRadius: Config.appearance.rounding.lg

  Loader {
    id: musicLoader

    active: root.showMusic
    anchors.fill: parent

    anchors.leftMargin: 12
    anchors.rightMargin: 12

    sourceComponent: RowLayout {
      id: musicContent

      anchors.verticalCenter: parent.verticalCenter

      ShinyClippingRectangle {
        width: 96
        height: 96
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
        ShinyText {
          text: Player.preferred.trackTitle || "Unknown Title"
          font.pointSize: Config.appearance.font.size.lg
          font.weight: Font.Medium
        }

        ShinyText {
          text: Player.preferred.trackArtist || "Unknown Artist"
          font.pointSize: Config.appearance.font.size.md
          font.weight: Font.Light
        }
      }
    }
  }

  Icon {
    id: musicOff

    anchors.centerIn: parent
    visible: !root.showMusic
    icon: "music_off"
    font.weight: Font.DemiBold
    font.pointSize: Config.appearance.font.size.xl
  }

  Behavior on implicitWidth {
    NumberAnimation {
      duration: Config.appearance.anim.durations.md
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Config.appearance.anim.curves.standard
    }
  }
}
