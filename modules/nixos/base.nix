{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops

    #./_packages.nix
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
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.a4blue_hashed_password.neededForUsers = true;
  };

  #users.mutableUsers = false;
  users.users.a4blue = {
    isNormalUser = true;
    description = "Alexander Ratajczak";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb2erO3CjSDZdQNfU720I4vxt1K5XzECQ/ncROZmA2X a4blue"
    ];
    home = /home/a4blue;
    #shell = pkgs.zsh;
    #hashedPasswordFile = config.sops.secrets.a4blue_hashed_password.path;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
    #fstrim.enable = true;
  };

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  #programs.zsh.enable = true;
  #security.sudo.wheelNeedsPassword = false;
  #time.timeZone = "America/New_York";
  #zramSwap.enable = true;

  #environment.persistence."/nix/persist" = {
  # Hide these mounts from the sidebar of file managers
  #  hideMounts = true;

  #  directories = [
  #    "/var/log"
  #  ];

  #  files = [
  #    "/etc/machine-id"
  #    "/etc/ssh/ssh_host_ed25519_key.pub"
  #    "/etc/ssh/ssh_host_ed25519_key"
  #    "/etc/ssh/ssh_host_rsa_key.pub"
  #    "/etc/ssh/ssh_host_rsa_key"
  #  ];
  #};

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
