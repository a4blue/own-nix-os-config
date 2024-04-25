{
  pkgs,
  config,
  lib,
  ...
}: let
  unmanic = import ./derivation.nix {inherit pkgs lib;};
in {
  systemd.services."unmanic" = {
    enable = true;
    script = ''
      ${unmanic}/bin/unmanic
    '';
    environment = {
      HOME_DIR = "/var/lib/unmanic";
      CACHE_DIR = "/tmp/unmanic";
    };
    serviceConfig = {
      User="root";
    };
    path = [
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
  };
  networking.firewall.allowedTCPPorts = [8888];
}
