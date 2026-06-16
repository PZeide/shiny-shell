self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.programs.shiny-shell-greeter;

  toLua = lib.generators.toLua {};

  renderLuaArgs = value:
    if lib.isAttrs value && value ? _args
    then lib.concatMapStringsSep ", " toLua value._args
    else toLua value;

  renderLuaCalls = name: values:
    lib.concatMapStringsSep "\n" (value: "hl.${name}(${renderLuaArgs value})") (
      if lib.isList values
      then values
      else [values]
    );

  shinyShellConf = pkgs.writeText "shiny-shell-greeter.json" (builtins.toJSON cfg.settings);

  hyprConf = pkgs.writeText "shiny-shell-greeter-hyprland.lua" ''
    hl.config(${toLua {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
      };

      decoration = {
        rounding = 0;

        blur.enabled = false;
        shadow.enabled = false;
      };

      animations.enabled = false;

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        disable_autoreload = true;
        background_color = "rgb(000000)";
      };

      xwayland.enabled = false;

      cursor = {
        invisible = true;
        no_hardware_cursors = 0;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      input = cfg.hyprlandSettings.input;
    }})

    ${renderLuaCalls "monitor" cfg.hyprlandSettings.monitor}
    ${renderLuaCalls "device" cfg.hyprlandSettings.device}

    hl.env("SHINYSHELL_CONFIG", ${toLua shinyShellConf})
    hl.env("SHINYSHELL_GREETER_SESSION", ${toLua cfg.session})
    hl.env("SHINYSHELL_GREETER_USER", ${toLua cfg.user})

    hl.on("hyprland.start", function()
      hl.exec_cmd(${toLua "${cfg.package}/bin/shiny-shell-greeter; ${cfg.hyprlandPackage}/bin/hyprctl dispatch exit"})
    end)
  '';

  greeterSession = pkgs.writeShellScript "shiny-shell-greeter-session" ''
    exec ${cfg.hyprlandPackage}/bin/start-hyprland -- --config ${hyprConf} >/dev/null 2>&1
  '';
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

      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "Shiny Shell settings to use for the greeter";
      };

      hyprlandSettings = mkOption {
        type = types.submodule {
          options = {
            monitor = mkOption {
              type = with types; either attrs (listOf attrs);
              default = {
                output = "";
                mode = "preferred";
                position = "auto";
                scale = "auto";
              };
              description = "Hyprland monitor settings to use for the greeter";
            };

            input = mkOption {
              type = types.attrs;
              default = {};
              description = "Hyprland input settings to use for the greeter";
            };

            device = mkOption {
              type = with types; either attrs (listOf attrs);
              default = [];
              description = "Hyprland device settings to use for the greeter";
            };
          };
        };
        default = {};
        description = "Hyprland settings to use for the greeter";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${greeterSession}";
          user = "greeter";
        };
      };
    };
  };
}
