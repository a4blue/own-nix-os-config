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
  ];

  home = {
    username = "a4blue";
    homeDirectory = "/home/a4blue";
    stateVersion = "25.05";
    keyboard = null;
  };

  home.packages = with pkgs; [
    wget
    curl
    home-manager
    sops
    just
    inputs.own-nixvim.packages.${system}.default
    nvd
  ];

  # Enable default Programs (only non-gui allowed)
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.navi.enable = true;
  programs.zellij.enable = true;
  programs.bottom.enable = true;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";

  systemd.user.startServices = "sd-switch";
}
