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
      User = "root";
    };
  };
  networking.firewall.allowedTCPPorts = [8888];
}
