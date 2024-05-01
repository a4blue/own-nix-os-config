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
    inputs.nix-ld.nixosModules.nix-ld
    ../../modules/nixos/base.nix
    ../../modules/nixos/home-manager-base.nix
  ];

  home-manager.users = {
    a4blue = {
      imports = [
        ./../../modules/home-manager/base.nix
      ];
    };
    nixos = {
      home = {
        username = "nixos";
        homeDirectory = "/home/nixos";
        stateVersion = "24.05";
        keyboard = null;
      };
    };
  };

  programs.nix-ld.dev.enable = true;

  programs.nix-ld.dev.libraries = with pkgs; [
    pkgs.stdenv.cc.cc
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  system.stateVersion = "24.05"; # Did you read the comment?
}
