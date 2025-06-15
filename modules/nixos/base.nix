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
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      extra-substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
      connect-timeout = 30;
      download-attempts = 1;
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
      # Nitrokey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPFRV7ZJOgn9N5DBl4b+NwjTWNXJURDBd761JGB8ZZm+AAAABHNzaDo="
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINQzo89EsYmlmVZSJrsPWUapwQofmpDbjYAMTE1E7N6AAAAAC3NzaDpIb21lTmV0 ssh:HomeNet"
      # Nitrokey Home Backup
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPYowMyQtbljcuZZDerqqxbukUmUG8IJdAfgck/00+NgAAAAC3NzaDpIb21lTmV0 ssh:HomeNet"
    ];
    hashedPasswordFile = config.sops.secrets.a4blue_easy_hashed_password.path;
  };
}
