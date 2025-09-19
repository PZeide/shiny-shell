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
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (
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

          shellHook = let
            fontconfig = pkgs.makeFontsConf {
              fontDirectories = with pkgs; [
                material-symbols
                nerd-fonts.symbols-only
                librebarcode-fonts
              ];
            };
          in ''
            # Required to allow meson to find some qtdeclarative binaries
            export PATH=${pkgs.qt6.qtdeclarative}/libexec:$PATH

            meson setup builddir
            ninja -C builddir

            # Add our plugin to the QML path
            export QML2_IMPORT_PATH="$PWD/builddir/plugin/qml:''${QML2_IMPORT_PATH:-}"

            export FONTCONFIG_FILE="${fontconfig}"
            export QS_ENVIRONMENT="dev"
          '';
        };

        packages = rec {
          inherit shiny-shell;
          default = shiny-shell;
        };
      }
    );
}
