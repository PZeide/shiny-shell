pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components
import qs.layers.lockscreen.components as LockComponents

Loader {
  active: Audio?.defaultSink?.audio !== null
  width: (item as Item)?.width || 0
  height: parent.height

  sourceComponent: LockComponents.SystemModuleWrapper {
    id: root

    ShinyInteractiveLayer {
      id: layer
      anchors.fill: parent
      layerRadius: Config.appearance.rounding.xs

      onPressed: Audio.defaultSink.audio.muted = !Audio.defaultSink.audio.muted
    }

    contentItem: Item {
      implicitWidth: parent.implicitHeight

      ShinyIcon {
        anchors.centerIn: parent
        icon: Audio.defaultSink.audio.muted ? "volume_off" : "volume_up"
        font.pointSize: Config.appearance.font.size.lg
      }
    }
  }
}
