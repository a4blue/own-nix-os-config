# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
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
    inputs.sops-nix.homeManagerModules.sops
  ];

  #  nixpkgs = {
  # You can add overlays here
  #    overlays = [
  # If you want to use overlays exported from other flakes:
  # neovim-nightly-overlay.overlays.default

  # Or define it inline, for example:
  # (final: prev: {
  #   hi = final.hello.overrideAttrs (oldAttrs: {
  #     patches = [ ./change-hello-to-hi.patch ];
  #   });
  # })
  #    ];
  # Configure your nixpkgs instance
  #    config = {
  # Disable if you don't want unfree packages
  #      allowUnfree = true;
  # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #      allowUnfreePredicate = _: true;
  #    };
  #  };

  # TODO: Set your username
  home = {
    username = "a4blue";
    homeDirectory = "/home/a4blue";
    stateVersion = "23.11";
    file = {
      ".ssh/ssh_key.pub".text = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb2erO3CjSDZdQNfU720I4vxt1K5XzECQ/ncROZmA2X
        '';
      ".ssh/git_key.pub".text = ''
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCteIbPetVO7CbrG4MC/CByDR84ccNZxAKiwPM29tHaFTNak/xfn5rfneYJ29DH+cnOa4uq7W52yMbJaEOaaJ5pQ1E+MB1ZXlj9+qGRf4TnLTyIh50cfKr9hDLZwz8qRllMkyhGeK2D2blzle33yclIKz5cFcUzATa6W2RtX5UVcGf1KrtEes29l8mHrxro5Y4WBlp1bZg9zthjuy5GFXsBB/Q8/fLV380R2kWj8UFMWCeK8PN7H8GTrBLQl3ObQYPNUg9wXcAg4za/Vsr4Aq0iY3NytsplLVnmnreEhi68tO6T1k7FA0BDkxLtkRCFC5VX7hrNzUb0txvsLXuADEl5BvhsB7ChSxn+uuZ8aIsbEuoXPuH2QW56rlmF8ZEBapCKYILgr8eVy10XWEe9EzQ0SQ5Q5KoFvhzf+QpRuYQbLZ7b+D7kKXkCUVt6LGrCoJTrnkYmGBxCW7loHu8XQ23QaGMZFK6lJayWXwqpmtcT7xjRZ/kIor5oPoFEO3aFVr8=
      '';
    };
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
    extraConfig = {
      commit.gpgsign = true;

    };
  };

  sops = {
    # Example Generation:
    # age-keygen -o ~/.config/sops/age/keys.txt
    age.keyFile = "~/.config/sops/age/keys.txt"; # must have no password!
    defaultSopsFile = ./secrets.yaml;

    secrets.a4blue_ssh_key_private = {
      mode = "0440";
      owner = config.users.users.a4blue.name;
      group = config.users.users.a4blue.group;
      path = "%r/.ssh/ssh_key"; 
    };

    secrets.a4blue_git_key_private = {
      mode = "0440";
      owner = config.users.users.a4blue.name;
      group = config.users.users.a4blue.group;
      path = "%r/.ssh/git_key"; 
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
