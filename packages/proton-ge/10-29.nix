{
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  name = "proton-ge-10-29";
  src = fetchzip {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-29/GE-Proton10-29.tar.gz";
    hash = "sha256-ATtKLEKA+r557FVnBoW/iYrRR4Ki9G8rjlV4+2rki0I=";
  };
  installPhase = ''
    cp -R $src $out
  '';
}
