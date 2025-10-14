{
  description = "Shiny Shell | @PZeide";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/staging-next";
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

        librebarcode-fonts = pkgs.callPackage ./nix/librebarcode-fonts.nix {};

        shiny-shell = pkgs.callPackage ./nix/default.nix {
          rev = self.rev or self.dirtyRev;

          quickshell = quickshell.packages.${system}.default.override {
            withX11 = false;
            withI3 = false;
          };

          inherit librebarcode-fonts;
        };
      in {
        devShells.default = pkgs.mkShell {
          inputsFrom = [shiny-shell shiny-shell.plugin];

          packages = with pkgs; [
            jost
            iosevka
            material-symbols
            nerd-fonts.symbols-only
            librebarcode-fonts
          ];

          shellHook = ''
            # Add our plugin to the QML path
            export QML2_IMPORT_PATH="$PWD/build/qml:''${QML2_IMPORT_PATH:-}"

            export QS_ENVIRONMENT="dev"
          '';
        };

        packages = rec {
          inherit shiny-shell;
          default = shiny-shell;
        };
      }
    ))
    // {
      homeManagerModules.default = import ./nix/hm-module.nix self;
    };
}
