{pkgs,lib}:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "unmanic";
  format = "wheel";
  version = "0.2.6";
  src = pkgs.python3Packages.fetchPypi {
    inherit pname version format;
    sha256 = "sha256-tbjqOvBetQ3c+IZCFDdenTS8GnBEccDJJIa7QQQVTOk=";
    dist = "py3";
    python = "py3";
  };

  dependencies = [
    pkgs.psutils
    pkgs.python3Packages.schedule
    pkgs.python3Packages.tornado
    pkgs.python3Packages.marshmallow
    pkgs.python3Packages.peewee
    pkgs.python3Packages.peewee-migrate
    pkgs.python3Packages.psutil
    pkgs.python3Packages.requests
    pkgs.python3Packages.requests-toolbelt
    pkgs.python3Packages.py-cpuinfo
    pkgs.python3Packages.watchdog
    pkgs.python3Packages.inquirer
  ];

  meta = with lib; {
    description = "Unmanic - Library Optimiser";
    homepage = "https://docs.unmanic.app/";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    mainProgram = "unmanic";
  };
}
