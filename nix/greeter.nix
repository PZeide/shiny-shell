self: {
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.programs.shiny-shell-greeter;

  hasHomeManager = config ? home-manager;
  userExists = hasHomeManager && (config.home-manager.users ? "${cfg.user}");

  userShinyShellSettings =
    if userExists
    then config.home-manager.users.${cfg.user}.programs.shiny-shell.settings
    else {};

  userHyprlandSettings =
    if userExists
    then config.home-manager.users.${cfg.user}.wayland.windowManager.hyprland.settings
    else {};

  shinyShellConf = pkgs.writeText "shiny-shell-greeter.json" (builtins.toJSON userShinyShellSettings);

  baseHyprConfig = ''
    general {
      gaps_in = 0
      gaps_out = 0
      border_size = 0
    }

    decoration {
      rounding = 0

      blur {
        enabled = false
      }

      shadow {
        enabled = false
      }

      animations {
        enabled = false
      }
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      disable_autoreload = true
      background_color = rgb(000000)
    }

    xwayland {
      enabled = false
    }

    cursor {
      invisible = true
      no_hardware_cursors = 0
    }

    ecosystem {
      no_update_news = true
      no_donation_nag = true
    }

    env = SHINYSHELL_CONFIG,${shinyShellConf}
    env = SHINYSHELL_GREETER_SESSION,${cfg.session}
    env = SHINYSHELL_GREETER_USER,${cfg.user}

    exec-once = ${cfg.package}/bin/shiny-shell-greeter; ${cfg.hyprlandPackage}/bin/hyprctl dispatch exit
  '';

  monitorHyprConfig = ''
    monitor = , preferred, auto, auto
  '';

  userHyprConfig = {
    monitor =
      if userHyprlandSettings ? monitor
      then userHyprlandSettings.monitor
      else [", preferred, auto, auto"];

    input =
      if userHyprlandSettings ? input
      then userHyprlandSettings.input
      else {};

    device =
      if userHyprlandSettings ? device
      then userHyprlandSettings.device
      else [];
  };

  hyprConf = pkgs.writeText "shiny-shell-greeter-hyprland.conf" (
    if cfg.useHyprlandUserOptions
    then ''
      ${inputs.home-manager.lib.hm.generators.toHyprconf {
        attrs = userHyprConfig;
        importantPrefixes = config.home-manager.users.${cfg.user}.wayland.windowManager.hyprland.importantPrefixes;
      }}
      ${baseHyprConfig}
    ''
    else ''
      ${monitorHyprConfig}
      ${baseHyprConfig}
    ''
  );
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

      user = mkOption {
        type = types.str;
        description = "User to open when the greeter is run";
      };

      session = mkOption {
        type = types.str;
        description = "Session to open when the greeter is run";
      };

      useShinyShellUserOptions = mkEnableOption "the usage of Shiny Shell user options (home-manager is required)";
      useHyprlandUserOptions = mkEnableOption "the usage of Hyprland user options (home-manager is required)";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.useShinyShellUserOptions -> userExists;
        message = "programs.shiny-shell-greeter: useShinyShellUserOptions is enabled but home-manager is not found or user '${cfg.user}' is not defined.";
      }
      {
        assertion = cfg.useHyprlandUserOptions -> userExists;
        message = "programs.shiny-shell-greeter: useHyprlandUserOptions is enabled but home-manager is not found or user '${cfg.user}' is not defined.";
      }
    ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${cfg.hyprlandPackage}/bin/start-hyprland -- --config ${hyprConf}";
          user = "greeter";
        };
      };
    };
  };
}
