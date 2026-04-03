{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./system-packages.nix
  ];
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "26.05";
  sops.secrets.githubPat = {mode = "0777";};

  nix = {
    package = pkgs.nixVersions.latest;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = false;
      extra-substituters = [
        "http://ncps.homelab.internal:8501"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "ncps.homelab.internal:8j2IwS6XdP3mpY8JoLVl8TCClJv1bllrNfGQP4B2kyI="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      connect-timeout = 30;
      download-attempts = 1;
      max-jobs = 2;
      download-buffer-size = 524288000;
    };
    extraOptions = ''
      !include ${config.sops.secrets.githubPat.path}
    '';
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/nix/secret/initrd/ssh_host_ed25519_key"];
    secrets.a4blueEasyHashedPassword.neededForUsers = true;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = -1;
    }
    {
      domain = "a4blue";
      type = "-";
      item = "nofile";
      value = -1;
    }
    {
      domain = "@users";
      type = "-";
      item = "nofile";
      value = -1;
    }
  ];

  services.orca.enable = false;

  users = {
    mutableUsers = false;
    users.a4blue = {
      isNormalUser = true;
      description = "Alexander Ratajczak";
      extraGroups = ["networkmanager" "wheel"];
      openssh.authorizedKeys.keys = [
        # Termux Pixel7Pro
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYaqu6PwownHMqXluc61CdJLkJE3WOEtEOyKqKd+zXP"
        # Nitrokey
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPFRV7ZJOgn9N5DBl4b+NwjTWNXJURDBd761JGB8ZZm+AAAABHNzaDo="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINQzo89EsYmlmVZSJrsPWUapwQofmpDbjYAMTE1E7N6AAAAAC3NzaDpIb21lTmV0 ssh:HomeNet"
        # Nitrokey Backup
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFe4fmeT6W1f3+YBrRlR5DBjQ1Xo0WNi6j+ptstlXGO5AAAAD3NzaDpIb21lTmV0LUJhaw== ssh:HomeNet-Bak"
        # TPM Laptop
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBhNZQ98YEqc0WbcTsXyy8hjysL5T4vAfqOx5aidPPIzkpHj9iuAWjjIkUXuI08szM5VMpEN7TcjVy+b7ULyoik="
        # TPM Desktop
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLvA3EpJmiAhmGggV7xJPnw/cnsUa9wY1BX9qmyUNfjIoQgoFIeRFNvAYgodIz0+UnHt/nPKpkzHKQjvrkhdLBQ="
      ];
      hashedPasswordFile = config.sops.secrets.a4blueEasyHashedPassword.path;
      uid = 1000;
    };
    users.root = {
      name = "root";
      isSystemUser = true;
      hashedPasswordFile = config.sops.secrets.a4blueEasyHashedPassword.path;
    };
  };
}
