{
  inputs,
  lib,
  config,
  pkgs,
  home,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  home.persistence."/persistent/home/a4blue" = {
    allowOther = true;
    directories = [
      ".ssh"
      "nixos-git"
    ];
  };
}
