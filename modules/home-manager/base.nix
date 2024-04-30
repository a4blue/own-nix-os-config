{
  inputs,
  lib,
  config,
  pkgs,
  home,
  ...
}: {
  home = {
    username = "a4blue";
    homeDirectory = "/home/a4blue";
    stateVersion = "24.05";
    keyboard = null;
  };

  home.packages = with pkgs; [
    vim
    wget
    htop
    git
    home-manager
    nano
    curl
    ranger
    tmux
    sops
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Alexander Ratajczak";
    userEmail = "a4blue@hotmail.de";
  };

  #sops = {
  # Example Generation:
  # age-keygen -o ~/.config/sops/age/keys.txt
  #age.keyFile = "~/.config/sops/age/keys.txt"; # must have no password!
  #defaultSopsFile = ./secrets.yaml;
  #};

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
