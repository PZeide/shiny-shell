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

        quickshellPackage = quickshell.packages.${system}.default;

        qtDependencies = with pkgs.qt6; [
          qtbase
          qtdeclarative
        ];

        dependencies = with pkgs; [
          quickshellPackage
          rembg
        ];
      in {
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = [quickshellPackage] ++ qtDependencies ++ dependencies;
        };

        packages = rec {
          shiny-shell = pkgs.callPackage ./default.nix {
            rev = self.rev or self.dirtyRev;
            quickshell = quickshellPackage.override {
              withX11 = false;
              withI3 = false;
            };
          };

          default = shiny-shell;
        };
      }
    );
}
