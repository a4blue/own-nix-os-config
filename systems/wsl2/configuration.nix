{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    ../../modules/nixos/base.nix
    ../../modules/nixos/home-manager-base.nix
  ];

  home-manager.users = {
    a4blue = {
      imports = [
        ./../../modules/home-manager/base.nix
      ];
    };
  };

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  system.stateVersion = "24.05"; # Did you read the comment?
}
