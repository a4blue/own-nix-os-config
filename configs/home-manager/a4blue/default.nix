{
  pkgs,
  config,
  inputs,
  ...
}:
with config; {
  imports = [
    ./vscode.nix
    ./firefox.nix
    ./git.nix
    ./alacritty.nix
    ./fontconfig.nix
    ./wezterm.nix
    ./navi.nix
    ./zellij.nix
    ./bottom.nix
    ./joshuto.nix
    ./ssh.nix
    ./gaming.nix
    ./graphical-apps.nix
    ./gnupg-agent.nix
    ./pipewire.nix
    ../common
  ];

  home = {
    username = "a4blue";
    homeDirectory = "/home/a4blue";
    stateVersion = "25.11";
    keyboard = null;
    packages = with pkgs; [
      wget
      curl
      home-manager
      sops
      just
      inputs.own-nixvim.packages.${system}.default
      nvd
      wireguard-tools
    ];
  };
  # Enable default Programs (only non-gui allowed)
  programs = {
    home-manager.enable = true;
    git.enable = true;
    navi.enable = true;
    zellij.enable = true;
    bottom.enable = true;
  };

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";

  systemd.user.startServices = "sd-switch";
}
