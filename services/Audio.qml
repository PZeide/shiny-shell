pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
  id: root

  readonly property PwNode defaultSink: Pipewire.defaultAudioSink
  readonly property PwNode defaultSource: Pipewire.defaultAudioSource

  readonly property bool sinkMuted: !!defaultSink?.audio?.muted
  readonly property real sinkVolume: defaultSink?.audio?.volume ?? 0
  readonly property bool sourceMuted: !!defaultSource?.audio?.muted
  readonly property real sourceVolume: defaultSource?.audio?.volume ?? 0

  function setAudioSink(newSink: PwNode): void {
    Pipewire.preferredDefaultAudioSink = newSink;
  }

  function setAudioSource(newSource: PwNode): void {
    Pipewire.preferredDefaultAudioSource = newSource;
  }

  PwObjectTracker {
    objects: [root.defaultSink, root.defaultSource]
  }
}
