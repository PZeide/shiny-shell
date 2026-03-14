{
  description = "Shiny Shell | @PZeide";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    quickshell,
    ...
  }:
    (flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        shiny-shell = pkgs.callPackage ./nix/default.nix {
          rev = self.rev or self.dirtyRev;

          quickshell =
            (quickshell.packages.${system}.default.override {
              withX11 = false;
              withI3 = false;
            }).withModules [
              pkgs.qt6.qtsvg
              pkgs.qt6.qtimageformats
              pkgs.qt6.qtmultimedia
            ];
        };
      in {
        devShells.default = pkgs.mkShell {
          inputsFrom = [shiny-shell shiny-shell.plugin];

          packages = with pkgs; [
            # Fonts for development tools
            vegur
            iosevka
            material-symbols
            nerd-fonts.symbols-only
          ];

          shellHook = ''
            export SHINYSHELL_ENVIRONMENT="dev"
            export SHINYSHELL_CONFIG="$PWD/dev/config-dev.json"

            # Add our plugin to the QML path
            export QML2_IMPORT_PATH="$PWD/build/qml:''${QML2_IMPORT_PATH:-}"
          '';
        };

        packages = rec {
          inherit shiny-shell;
          default = shiny-shell;
        };
      }
    ))
    // {
      nixosModules.greeter = import ./nix/greeter.nix self;
      homeManagerModules.default = import ./nix/hm-module.nix self;

      nixosConfigurations.test-greeter-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [(import ./dev/greeter-vm.nix self)];
      };
    };
}
