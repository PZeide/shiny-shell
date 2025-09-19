{
  lib,
  rev,
  stdenv,
  stdenvNoCC,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  qt6,
  quickshell,
  material-symbols,
  nerd-fonts,
  librebarcode-fonts,
  makeFontsConf,
  nushell,
  rembg,
  libqalculate,
  ...
}: let
  plugin = stdenv.mkDerivation {
    name = "shiny-shell-plugin";
    src = lib.fileset.toSource {
      root = ./..;
      fileset = lib.fileset.union ./../meson.build ./../plugin;
    };

    nativeBuildInputs = [meson ninja pkg-config];
    buildInputs = [qt6.qtbase qt6.qtdeclarative];
    dontWrapQtApps = true;

    mesonFlags = [
      "-Dplugin-install-dir=${qt6.qtbase.qtQmlPrefix}"
    ];

    preConfigure = ''
      export PATH=${qt6.qtdeclarative}/libexec:$PATH
    '';
  };

  runtimeDeps = [
    nushell
    rembg
    libqalculate
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

    src = ./..;

    nativeBuildInputs = [makeWrapper];
    buildInputs = [quickshell plugin];
    propagatedBuildInputs = runtimeDeps;

    installPhase = ''
      makeWrapper ${quickshell}/bin/qs $out/bin/shiny-shell \
      	--prefix PATH : "${lib.makeBinPath runtimeDeps}" \
      	--set FONTCONFIG_FILE "${fontconfig}" \
      	--add-flags '-p ${./..}'
    '';

    passthru = {
      inherit plugin;
    };

    meta = {
      description = "Shiny Shell | @PZeide";
      homepage = "https://github.com/pzeide/shiny-shell";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "shiny-shell";
    };
  }
