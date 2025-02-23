{
  pkgs,
  config,
  ...
}:
with config; {
  imports = [
    ./vscode.nix
    ./firefox.nix
    ./git.nix
  ];

  home = {
    username = "a4blue";
    homeDirectory = "/home/a4blue";
    stateVersion = "25.05";
    keyboard = null;
  };

  home.packages = with pkgs; [
    vim
    wget
    htop
    home-manager
    nano
    curl
    tmux
    sops
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";

  systemd.user.startServices = "sd-switch";
}
