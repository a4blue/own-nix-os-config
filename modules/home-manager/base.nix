{
  inputs,
  lib,
  config,
  pkgs,
  home,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    #inputs.sops-nix.homeManagerModules.
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home = {
    username = "a4blue";
    homeDirectory = "/home/a4blue";
    stateVersion = "23.11";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
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

  home.persistence."/nix/persist/home/a4blue" = {
    allowOther = true;
    directories = [
      ".ssh"
      "nixos-git"
    ];
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
