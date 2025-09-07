{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "librebarcode-fonts";
  version = "1.008";

  src = fetchFromGitHub {
    owner = "graphicore";
    repo = "librebarcode";
    tag = "v${version}";
    hash = "sha256-QDEas/Mwa2hkXjLWaIl/ugO9n1YNKQdaAHQq3HWTVH8=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp fonts/*.ttf $out/share/fonts/truetype
  '';

  meta = {
    description = "barcode fonts for various barcode standards";
    homepage = "https://graphicore.github.io/librebarcode/";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
