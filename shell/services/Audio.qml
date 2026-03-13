pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
  id: root

  readonly property real _LOG100: 4.60517018599

  readonly property PwNode defaultSink: Pipewire.defaultAudioSink
  readonly property PwNode defaultSource: Pipewire.defaultAudioSource
  readonly property list<PwNode> sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)
  readonly property list<PwNode> sources: Pipewire.nodes.values.filter(node => !node.isSink && !node.isStream && node.audio)
  readonly property list<PwNode> outputAppNodes: Pipewire.nodes.values.filter(node => node.isSink && node.isStream && node.audio)
  readonly property list<PwNode> inputAppNodes: Pipewire.nodes.values.filter(node => !node.isSink && node.isStream && node.audio)

  function setAudioSink(newSink: PwNode): void {
    Pipewire.preferredDefaultAudioSink = newSink;
  }

  function setAudioSource(newSource: PwNode): void {
    Pipewire.preferredDefaultAudioSource = newSource;
  }

  function volumeLinearToLog(volume: real): real {
    return 1 - Math.exp(-(Math.max(0, volume)) * _LOG100);
  }

  function volumeLogToLinear(volume: real): real {
    const convertedVolume = Math.max(0, volume);
    if (convertedVolume > 0.99) {
      return 1;
    }

    return -Math.log(1 - convertedVolume) / _LOG100;
  }

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource, Pipewire.nodes]
  }
}
