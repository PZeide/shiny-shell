self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.programs.shiny-shell;
in {
  options = with lib; {
    programs.shiny-shell = {
      enable = mkEnableOption "shiny-shell";

      package = mkOption {
        type = types.package;
        default = self.packages.${system}.default;
        description = "Package of shiny-shell";
      };

      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "shiny-sell settings";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.shiny-shell = {
      Unit = {
        Description = "shiny-shell";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        X-Restart-Triggers = lib.mkIf (cfg.settings != {}) [
          "${config.xdg.configFile."shiny-shell/config.json".source}"
        ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/caelestia-shell";
        Restart = "on-failure";
        Slice = "session.slice";
      };

      Install.WantedBy = ["graphical-session.target"];
    };

    xdg.configFile."shiny-shell/config.json".text = builtins.toJSON cfg.settings;

    home.packages = [cfg.package];
  };
}
