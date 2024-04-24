{
  pkgs,
  config,
  lib,
  ...
}: let
  unmanic = import ./derivation.nix {inherit pkgs;};
in {
  systemd.services."unmanic" = {
    enable = true;
    script = ''
      ${unmanic}/bin/unmanic
    '';
    environment = {
      HOME_DIR = "/var/lib/unmanic";
      CONFIG_DIR = "/var/lib/unmanic/config";
      CACHE_DIR = "/tmp/unmanic";
    };
  };
}
