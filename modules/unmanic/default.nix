{
  pkgs,
  config,
  ...
}:
pkgs.callPackage ./derivation.nix {
  #system.services."unmanic.service" = {
  #  enable = true;
  #  script = ''
  #    ${pkgs.unmanic}/bin/unmanic
  #  '';
  #  environment = {
  #    HOME_DIR = "/var/lib/unmanic";
  #  };
  #};
}
