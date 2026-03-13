pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.config
import qs.utils

Singleton {
  id: root

  readonly property url placeholderTrackArt: Paths.assetUrl("images/placeholder_track_art.png")
  readonly property list<MprisPlayer> players: Mpris.players.values.filter(player => !isBlacklisted(player))
  readonly property MprisPlayer preferred: {
    if (players.length === 0)
      return null;

    const preferred = Config.player.preferred.map(entry => entry.toLowerCase());
    for (const candidate of players) {
      const identity = candidate.identity.toLowerCase();
      const desktopEntry = candidate.desktopEntry.toLowerCase();
      const dbusName = candidate.dbusName.toLowerCase();

      const match = preferred.find(entry => {
        return identity === entry || desktopEntry === entry || dbusName === entry;
      });

      if (match)
        return candidate;
    }

    return players[0];
  }

  function isBlacklisted(player: MprisPlayer): bool {
    const identity = player.identity.toLowerCase();
    const desktopEntry = player.desktopEntry.toLowerCase();
    const dbusName = player.dbusName.toLowerCase();

    return Config.player.blacklist.find(blacklistEntry => {
      blacklistEntry = blacklistEntry.toLowerCase();
      return identity === blacklistEntry || desktopEntry === blacklistEntry || dbusName === blacklistEntry;
    });
  }

  Timer {
    running: root.preferred !== null && root.preferred.playbackState == MprisPlaybackState.Playing
    interval: 1000
    repeat: true
    onTriggered: root.preferred.positionChanged()
  }

  IpcHandler {
    id: ipc
    target: "player"

    function status(): string {
      if (root.preferred !== null) {
        let state;
        if (root.preferred.playbackState == MprisPlaybackState.Playing) {
          state = "playing";
        } else if (root.preferred.playbackState == MprisPlaybackState.Paused) {
          state = "paused";
        } else {
          state = "stopped";
        }

        const result = {
          name: root.preferred.identity,
          dbusName: root.preferred.dbusName,
          desktopEntry: root.preferred.desktopEntry,
          state
        };

        if (state !== "stopped") {
          result.track = {
            title: root.preferred.trackTitle || "Unknown Title",
            artist: root.preferred.trackArtist || "Unknown Artist",
            album: root.preferred.trackAlbum || "Unknown Album",
            trackArtUrl: root.preferred.trackArtUrl || "Unknown Art URL",
            length: root.preferred.lengthSupported ? root.preferred.length : undefined,
            position: root.preferred.positionSupported ? root.preferred.position : undefined,
            volume: root.preferred.volumeSupported ? root.preferred.volume : undefined
          };
        }

        return Helpers.success(result);
      }

      return Helpers.fail("No player available");
    }

    function play(): string {
      if (root.preferred !== null && root.preferred.canPlay) {
        root.preferred.play();
        return Helpers.success(root.preferred.dbusName);
      }

      return Helpers.fail("No player available");
    }

    function pause(): string {
      if (root.preferred !== null && root.preferred.canPause) {
        root.preferred.pause();
        return Helpers.success(root.preferred.dbusName);
      }

      return Helpers.fail("No player available");
    }

    function playPause(): string {
      if (root.preferred !== null && root.preferred.canTogglePlaying) {
        root.preferred.togglePlaying();
        return Helpers.success(root.preferred.dbusName);
      }

      return Helpers.fail("No player available");
    }

    function stop(): string {
      if (root.preferred !== null) {
        root.preferred.stop();
        return Helpers.success(root.preferred.dbusName);
      }

      return Helpers.fail("No player available");
    }

    function next(): string {
      if (root.preferred !== null && root.preferred.canGoNext) {
        root.preferred.next();
        return Helpers.success(root.preferred.dbusName);
      }

      return Helpers.fail("No player available");
    }

    function previous(): string {
      if (root.preferred !== null && root.preferred.canGoPrevious) {
        root.preferred.previous();
        return Helpers.success(root.preferred.dbusName);
      }

      return Helpers.fail("No player available");
    }
  }
}
