self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.programs.shiny-shell;

  baseConfig = ''
    monitor = ,preferred, auto, auto
    env=XDG_CURRENT_DESKTOP,Hyprland
    exec-once = ${cfg.package}/bin/shiny-shell-greeter

    misc {
      force_default_wallpaper = 1
      disable_hyprland_logo = true
    }
  '';

  hyprConf = pkgs.writeText "hyprland.conf" (lib.strings.concatLines [
    baseConfig
  ]);
in {
  options = with lib; {
    programs.shiny-shell-greeter = {
      enable = mkEnableOption "shiny-shell greeter";

      package = mkOption {
        type = types.package;
        default = self.packages.${system}.default;
        description = "Package to use for shiny-shell-greeter";
      };

      hyprlandPackage = mkOption {
        type = types.package;
        default = pkgs.hyprland;
        description = "Hyprland package to use for the greeter";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.hyprlandPackage}/bin/start-hyprland -- --config ${hyprConf}";
        };
      };
    };
  };
}
