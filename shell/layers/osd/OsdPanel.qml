pragma ComponentBehavior: Bound

import QtQuick
import qs.components
import qs.config
import qs.layers.osd.types

ShinyRectangle {
  id: root

  required property int type
  readonly property bool interactionActive: (wrapperLoader.item as OsdTypeWrapper)?.interactionActive ?? false

  implicitWidth: (wrapperLoader.item as OsdTypeWrapper)?.width ?? 0
  implicitHeight: (wrapperLoader.item as OsdTypeWrapper)?.height ?? 0
  radius: Config.appearance.rounding.sm

  Loader {
    id: wrapperLoader

    sourceComponent: {
      switch (root.type) {
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
