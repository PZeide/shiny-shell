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

        quickshell-package = quickshell.packages.${system}.default;
        librebarcode-fonts = pkgs.callPackage ./nix/librebarcode-fonts.nix {};

        fontconfig = pkgs.makeFontsConf {
          fontDirectories = with pkgs; [
            material-symbols
            nerd-fonts.symbols-only
            librebarcode-fonts
          ];
        };
      in {
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = with pkgs; [
            quickshell-package
            nushell
            rembg
          ];

          shellHook = ''
            export FONTCONFIG_FILE="${fontconfig}"
            export QS_ENVIRONMENT="dev"
          '';
        };

        packages = rec {
          shiny-shell = pkgs.callPackage ./nix/default.nix {
            inherit librebarcode-fonts;
            rev = self.rev or self.dirtyRev;
            quickshell = quickshell-package.override {
              withX11 = false;
              withI3 = false;
            };
          };

          default = shiny-shell;
        };
      }
    );
}
