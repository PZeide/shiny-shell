{
  lib,
  rev,
  stdenvNoCC,
  makeWrapper,
  quickshell,
  material-symbols,
  nerd-fonts,
  librebarcode-fonts,
  makeFontsConf,
  rembg,
  curl,
  jq,
  ...
}: let
  runtimeDeps = [
    rembg
    curl
    jq
  ];

  fontconfig = makeFontsConf {
    fontDirectories = [
      material-symbols
      nerd-fonts.symbols-only
      librebarcode-fonts
    ];
  };
in
  stdenvNoCC.mkDerivation {
    pname = "shiny-version";
    version = "${rev}";

    src = ../.;

    nativeBuildInputs = [makeWrapper];
    buildInputs = [quickshell];
    propagatedBuildInputs = runtimeDeps;

    installPhase = ''
      makeWrapper ${quickshell}/bin/qs $out/bin/shiny-shell \
      	--prefix PATH : "${lib.makeBinPath runtimeDeps}" \
      	--set FONTCONFIG_FILE "${fontconfig}" \
      	--add-flags '-p ${./.}'
    '';

    meta = {
      description = "Shiny Shell | @PZeide";
      homepage = "https://github.com/pzeide/shiny-shell";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "shiny-shell";
    };
  }
