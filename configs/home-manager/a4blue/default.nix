{
  pkgs,
  config,
  inputs,
  pkgs-stable,
  ...
}:
with config;
{
  imports = [
    ./firefox.nix
    ./git.nix
    ./alacritty.nix
    ./fontconfig.nix
    ./wezterm.nix
    ./navi.nix
    ./bottom.nix
    ./ssh.nix
    ./gaming.nix
    ./graphical-apps.nix
    ./gnupg-agent.nix
    ./pipewire.nix
    ./zed.nix
    ./ghostty.nix
    ../common
  ];

  home = {
    username = "a4blue";
    homeDirectory = "/home/a4blue";
    stateVersion = "26.05";
    keyboard = null;
    packages = with pkgs; [
      wget
      curl
      home-manager
      sops
      just
      inputs.own-nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      nvd
      wireguard-tools
    ];
  };
  # Enable default Programs (only non-gui allowed)
  programs = {
    home-manager.enable = true;
    git.enable = true;
    navi.enable = true;
    bottom.enable = true;
  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";

  systemd.user.startServices = "sd-switch";
}
