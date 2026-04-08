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
  vegur,
  iosevka,
  material-symbols,
  nerd-fonts,
  makeFontsConf,
  rapidfuzz-cpp,
  libqalculate,
  app2unit,
  xdg-terminal-exec,
  gpu-screen-recorder,
  jq,
  ...
}: let
  plugin = stdenv.mkDerivation {
    name = "shiny-shell-plugin";

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
      rapidfuzz-cpp
      libqalculate
    ];

    dontWrapQtApps = true;

    cmakeFlags = [
      (lib.cmakeFeature "ENABLE_MODULES" "plugin")
      (lib.cmakeFeature "INSTALL_PLUGIN" qt6.qtbase.qtQmlPrefix)
    ];
  };

  runtimeDeps = [
    app2unit
    xdg-terminal-exec
    gpu-screen-recorder
  ];

  fontConfig = makeFontsConf {
    # Default fonts
    fontDirectories = [
      vegur
      iosevka
      material-symbols
      nerd-fonts.symbols-only
    ];
  };
in
  stdenv.mkDerivation {
    pname = "shiny-shell";
    version = "${rev}";
    src = lib.fileset.toSource {
      root = ./..;
      fileset = lib.fileset.unions [
        ./../CMakeLists.txt
        ./../shell
        ./../scripts
      ];
    };

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
        --set FONTCONFIG_FILE "${fontConfig}" \
      	--add-flags "-p $out/share/shiny-shell"

      makeWrapper ${quickshell}/bin/qs $out/bin/shiny-shell-greeter \
        --prefix PATH : "${lib.makeBinPath runtimeDeps}" \
        --set FONTCONFIG_FILE "${fontConfig}" \
       	--add-flags "-p $out/share/shiny-shell/greeter.qml"

      install -Dm755 $src/scripts/shiny-hyprland-share-picker.sh $out/bin/shiny-hyprland-share-picker
      wrapProgram $out/bin/shiny-hyprland-share-picker \
        --prefix PATH : "${lib.makeBinPath [jq]}:$out/bin"
    '';

    passthru = {
      inherit plugin;
    };

    meta = {
      description = "Shiny Shell | @PZeide";
      homepage = "https://github.com/PZeide/shiny-shell";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "shiny-shell";
    };
  }
