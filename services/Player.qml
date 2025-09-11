pragma ComponentBehavior: Bound
pragma Singleton

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

  IpcHandler {
    target: "player"

    function play() {
      if (root.preferred !== null && root.preferred.canPlay) {
        root.preferred.play();
      }
    }

    function pause() {
      if (root.preferred !== null && root.preferred.canPause) {
        root.preferred.pause();
      }
    }

    function togglePlaying() {
      if (root.preferred !== null && root.preferred.canTogglePlaying) {
        root.preferred.togglePlaying();
      }
    }

    function stop() {
      if (root.preferred !== null && root.preferred.stop) {
        root.preferred.stop();
      }
    }

    function next() {
      if (root.preferred !== null && root.preferred.canGoNext) {
        root.preferred.next();
      }
    }

    function previous() {
      if (root.preferred !== null && root.preferred.canGoPrevious) {
        root.preferred.previous();
      }
    }
  }
}
