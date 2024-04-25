{
  pkgs,
  lib,
}:
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

  dependencies = with pkgs.python3Packages; [
    pkgs.psutils
    schedule
    tornado
    marshmallow
    peewee
    peewee-migrate
    psutil
    requests
    requests-toolbelt
    py-cpuinfo
    watchdog
    inquirer
    markupsafe
    pyyaml
    blessed
    certifi
    charset-normalizer
    click
    editor
    idna
    inquirer
    jinja2
    packaging
    readchar
    runs
    schedule
    six
    #swagger-ui-py
    urllib3
    wcwidth
    xmod
  ];

  meta = with lib; {
    description = "Unmanic - Library Optimiser";
    homepage = "https://docs.unmanic.app/";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    mainProgram = "unmanic";
  };
}
