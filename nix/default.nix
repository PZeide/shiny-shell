{
  lib,
  rev,
  stdenv,
  makeWrapper,
  cmake,
  ninja,
  pkg-config,
  qt6,
  quickshell,
  jost,
  iosevka,
  material-symbols,
  nerd-fonts,
  librebarcode-fonts,
  makeFontsConf,
  rembg,
  rapidfuzz-cpp,
  libqalculate,
  app2unit,
  xdg-terminal-exec,
  ...
}: let
  plugin = stdenv.mkDerivation {
    name = "shiny-plugin";
    src = lib.fileset.toSource {
      root = ./..;
      fileset = lib.fileset.union ./../CMakeLists.txt ./../plugin;
    };

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
    ];

    buildInputs = [
      qt6.qtbase
      qt6.qtdeclarative
    ];

    dontWrapQtApps = true;

    cmakeFlags = [
      (lib.cmakeFeature "ENABLE_MODULES" "plugin")
      (lib.cmakeFeature "INSTALL_PLUGIN" qt6.qtbase.qtQmlPrefix)
    ];
  };

  runtimeDeps = [
    rembg
    rapidfuzz-cpp
    libqalculate
    app2unit
    xdg-terminal-exec
  ];

  fontconfig = makeFontsConf {
    # Default fonts
    fontDirectories = [
      jost
      iosevka
      material-symbols
      nerd-fonts.symbols-only
      librebarcode-fonts
    ];
  };
in
  stdenv.mkDerivation {
    pname = "shiny-version";
    version = "${rev}";
    src = ./..;

    nativeBuildInputs = [cmake ninja makeWrapper qt6.wrapQtAppsHook];
    buildInputs = [quickshell plugin qt6.qtbase];
    propagatedBuildInputs = runtimeDeps;

    cmakeFlags = [
      (lib.cmakeFeature "ENABLE_MODULES" "shell")
      (lib.cmakeFeature "INSTALL_SHELL" "${placeholder "out"}/share/shiny-shell")
    ];

    postInstall = ''
      makeWrapper ${quickshell}/bin/qs $out/bin/shiny-shell \
      	--prefix PATH : "${lib.makeBinPath runtimeDeps}" \
      	--add-flags "-p $out/share/shiny-shell"
    '';

    #	--set FONTCONFIG_FILE "${fontconfig}" \

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
