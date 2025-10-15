pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.config
import qs.utils
import qs.widgets

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
    id: ipc

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

    function playPause() {
      if (root.preferred !== null && root.preferred.canTogglePlaying) {
        root.preferred.togglePlaying();
      }
    }

    function stop() {
      root.preferred.stop();
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

  ShinyShortcut {
    name: "player-play"
    description: "Start playback on the preferred player"
    onPressed: ipc.play()
  }

  ShinyShortcut {
    name: "player-pause"
    description: "Pause playback on the preferred player"
    onPressed: ipc.pause()
  }

  ShinyShortcut {
    name: "player-playpause"
    description: "Toggle playback on the preferred player"
    onPressed: ipc.playPause()
  }

  ShinyShortcut {
    name: "player-stop"
    description: "Stop playback on the preferred player"
    onPressed: ipc.stop()
  }

  ShinyShortcut {
    name: "player-next"
    description: "Go to the next track on the preferred player"
    onPressed: ipc.next()
  }

  ShinyShortcut {
    name: "player-previous"
    description: "Go to the previous track on the preferred player"
    onPressed: ipc.previous()
  }
}
