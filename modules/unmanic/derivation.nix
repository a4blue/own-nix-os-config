{
  fetchPypi,
  pkgs,
}:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "unmanic";
  format = "wheel";
  version = "0.2.6";
  src = fetchPypi {
    inherit pname version format;
    sha256 = "sha256-tbjqOvBetQ3c+IZCFDdenTS8GnBEccDJJIa7QQQVTOk=";
    dist = "py3";
    python = "py3";
  };
  postInstall = ''
    ls
    mkdir -p /var/lib/unmanic
  '';
}
