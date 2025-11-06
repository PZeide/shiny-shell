pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.components.containers
import qs.config
import qs.layers.osd.types

ShinyLayerWrapper {
  id: layer

  required property int type
  property bool inhibitClose

  Loader {
    active: layer.shown && layer.type !== -1

    sourceComponent: ShinyWindow {
      name: "osd"
      screen: layer.screen
      anchors.bottom: true
      implicitWidth: drawer.implicitWidth
      implicitHeight: drawer.implicitHeight + Config.appearance.spacing.sm
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay

      mask: Region {
        item: drawer
      }

      ShinyRectangle {
        id: drawer
        implicitWidth: (activeLoader.item as OsdTypeWrapper).implicitWidth
        implicitHeight: (activeLoader.item as OsdTypeWrapper).implicitHeight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -implicitHeight + layer.animationFactor * (Config.appearance.spacing.sm + implicitHeight)

        Loader {
          id: activeLoader
          sourceComponent: {
            switch (layer.type) {
            case Osd.Type.AudioSink:
              return audioSinkComponent;
            case Osd.Type.AudioSource:
              return audioSourceComponent;
            case Osd.Type.Brightness:
              return brightnessComponent;
            default:
              return null;
            }
          }
        }

        Connections {
          target: activeLoader.item

          function onInhibitCloseChanged() {
            layer.inhibitClose = (activeLoader.item as OsdTypeWrapper).inhibitClose;
          }
        }

        Component {
          id: audioSinkComponent
          OsdAudioSink {}
        }

        Component {
          id: audioSourceComponent
          OsdAudioSource {}
        }

        Component {
          id: brightnessComponent
          OsdBrightness {}
        }
      }
    }
  }
}
