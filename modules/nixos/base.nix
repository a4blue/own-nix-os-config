{config, ...}: {
  imports = [
    ./system-packages.nix
    ./homepage-dashboard.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/nix/secret/initrd/ssh_host_ed25519_key"];
    #secrets.a4blue_hashed_password.neededForUsers = true;
    secrets.a4blue_easy_hashed_password.neededForUsers = true;
  };

  users.mutableUsers = false;
  users.users.a4blue = {
    isNormalUser = true;
    description = "Alexander Ratajczak";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      # Win11 DIY Powershell
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb2erO3CjSDZdQNfU720I4vxt1K5XzECQ/ncROZmA2X"
      # Win11 DIY WSL2 Ubuntu22.04
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIOPBiaBpAIpr9bTdZ6oWW+smZlywoeC8mh0Tz1R9IM"
      # Termux Pixel7Pro
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYaqu6PwownHMqXluc61CdJLkJE3WOEtEOyKqKd+zXP"
    ];
    #hashedPasswordFile = config.sops.secrets.a4blue_hashed_password.path;
    hashedPasswordFile = config.sops.secrets.a4blue_easy_hashed_password.path;
  };

  services.tailscale.enable = true;

  services = {
    openssh.enable = true;
    fstrim.enable = true;
  };

  networking.networkmanager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
