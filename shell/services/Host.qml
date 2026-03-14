pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property string fallbackOsIcon: ""
  readonly property var idToOsIcons: ({
      "almalinux": "",
      "alpine": "",
      "arch": "",
      "archcraft": "",
      "arcolinux": "",
      "artix": "",
      "centos": "",
      "debian": "",
      "devuan": "",
      "elementary": "",
      "endeavouros": "",
      "fedora": "",
      "freebsd": "",
      "garuda": "",
      "gentoo": "",
      "hyperbola": "",
      "kali": "",
      "linux": "",
      "linuxmint": "󰣭",
      "mageia": "",
      "openmandriva": "",
      "manjaro": "",
      "neon": "",
      "nixos": "",
      "opensuse": "",
      "suse": "",
      "sles": "",
      "sles_sap": "",
      "opensuse-tumbleweed": "",
      "parrot": "",
      "pop": "",
      "raspbian": "",
      "rhel": "",
      "rocky": "",
      "slackware": "",
      "solus": "",
      "steamos": "",
      "tails": "",
      "trisquel": "",
      "ubuntu": "",
      "vanilla": "",
      "void": "",
      "zorin": ""
    })
  property string osId
  property string osName
  property string osPrettyName
  property string osIcon

  FileView {
    path: "/etc/os-release"

    onLoaded: {
      const lines = text().split("\n");

      let id;
      let idLike;
      let name;
      let prettyName;
      let icon;

      for (const line of lines) {
        if (!line)
          continue;

        let [key, value] = line.split("=");
        value = value.replace("\"", "");

        switch (key) {
        case "ID":
          id = value;
          break;
        case "ID_LIKE":
          idLike = value;
          break;
        case "NAME":
          name = value;
          break;
        case "PRETTY_NAME":
          prettyName = value;
          break;
        }
      }

      if (id && root.idToOsIcons.hasOwnProperty(id)) {
        icon = root.idToOsIcons[id];
      } else if (idLike) {
        for (const candidate of idLike.split(" ")) {
          if (root.idToOsIcons.hasOwnProperty(candidate))
            icon = root.idToOsIcons[candidate];
        }
      }

      root.osId = id ?? "linux";
      root.osName = name ?? "Linux";
      root.osPrettyName = prettyName ?? "Linux";
      root.osIcon = icon ?? root.fallbackOsIcon;
    }
  }
}
