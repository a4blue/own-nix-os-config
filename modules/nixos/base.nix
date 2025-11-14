{
  config,
  inputs,
  ...
}: {
  imports = [
    ./system-packages.nix
  ];
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";
  sops.secrets.github_pat = {mode = "0777";};

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = false;
      extra-substituters = ["http://ncps.homelab.internal:8501" "https://nix-community.cachix.org"];
      trusted-public-keys = ["ncps.homelab.internal:8j2IwS6XdP3mpY8JoLVl8TCClJv1bllrNfGQP4B2kyI=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
      connect-timeout = 30;
      download-attempts = 1;
      max-jobs = 2;
      download-buffer-size = 524288000;
    };
    extraOptions = ''
      !include ${config.sops.secrets.github_pat.path}
    '';
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/nix/secret/initrd/ssh_host_ed25519_key"];
    secrets.a4blue_easy_hashed_password.neededForUsers = true;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
  ];

  systemd.extraConfig = "DefaultLimitNOFILE=65536:1048576";

  users.mutableUsers = false;
  users.users.a4blue = {
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
    ];
    hashedPasswordFile = config.sops.secrets.a4blue_easy_hashed_password.path;
  };
}
