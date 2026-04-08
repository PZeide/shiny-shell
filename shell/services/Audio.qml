pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.utils

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

  IpcHandler {
    id: ipc
    target: "audio"

    function toggleOutputMute(): string {
      root.defaultSink.audio.muted = !root.defaultSink.audio.muted;
      return Helpers.success(root.defaultSink.audio.muted);
    }

    function toggleInputMute(): string {
      root.defaultSource.audio.muted = !root.defaultSource.audio.muted;
      return Helpers.success(root.defaultSource.audio.muted);
    }

    function outputVolume(command: string): string {
      const result = Helpers.parseDecimalCommand(command.trim(), root.defaultSink.audio.volume);
      if (isNaN(result)) {
        return Helpers.fail(`invalid volume: ${command} (i.e: 0.1, +0.1, -0.1, 10%, +10%, -10%)`);
      }

      const clampedVolume = Math.min(Math.max(0, result), 1);
      root.defaultSink.audio.volume = clampedVolume;
      return Helpers.success(clampedVolume);
    }

    function inputVolume(command: string): string {
      const result = Helpers.parseDecimalCommand(command.trim(), root.defaultSource.audio.volume);
      if (isNaN(result)) {
        return Helpers.fail(`invalid volume: ${command} (i.e: 0.1, +0.1, -0.1, 10%, +10%, -10%)`);
      }

      const clampedVolume = Math.min(Math.max(0, result), 1);
      root.defaultSource.audio.volume = clampedVolume;
      return Helpers.success(clampedVolume);
    }

    function status(): string {
      const result = {};

      if (root.defaultSink) {
        result.output = {
          name: root.defaultSink.name,
          description: root.defaultSink.description,
          muted: root.defaultSink.audio.muted,
          volume: root.defaultSink.audio.volume
        };
      }

      if (root.defaultSource) {
        result.input = {
          name: root.defaultSource.name,
          description: root.defaultSource.description,
          muted: root.defaultSource.audio.muted,
          volume: root.defaultSource.audio.volume
        };
      }

      return Helpers.success(result);
    }
  }
}
