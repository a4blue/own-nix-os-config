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
        ../../modules/home-manager/base.nix
        ../../modules/home-manager/vscode-remote-wsl.nix
      ];
      own.vscode-remote-wsl = {
        enable = true;
        nixos-version = "unstable";
      };
    };
    nixos = {
      imports = [
        ../../modules/home-manager/vscode-remote-wsl.nix
      ];
      own.vscode-remote-wsl = {
        enable = true;
        nixos-version = "unstable";
      };
      home = {
        username = "nixos";
        homeDirectory = "/home/nixos";
        stateVersion = "24.05";
        keyboard = null;
      };
    };
  };

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    pkgs.stdenv.cc.cc
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.docker-desktop.enable = true;

  system.stateVersion = "24.05";
}
