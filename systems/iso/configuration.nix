{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./../../modules/nixos/system-packages.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      # Termux Pixel7Pro
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYaqu6PwownHMqXluc61CdJLkJE3WOEtEOyKqKd+zXP"
      # Nitrokey
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPFRV7ZJOgn9N5DBl4b+NwjTWNXJURDBd761JGB8ZZm+AAAABHNzaDo="
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINQzo89EsYmlmVZSJrsPWUapwQofmpDbjYAMTE1E7N6AAAAAC3NzaDpIb21lTmV0 ssh:HomeNet"
      # Nitrokey Backup
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFe4fmeT6W1f3+YBrRlR5DBjQ1Xo0WNi6j+ptstlXGO5AAAAD3NzaDpIb21lTmV0LUJhaw== ssh:HomeNet-Bak"
    ];
  };

  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "thunderbolt" "usbhid" "uas"];
    supportedFilesystems.bcachefs = true;
    boot.supportedFilesystems.zfs = lib.mkForce false;

    kernelModules = ["kvm-intel" "kvm-amd"];
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      openFirewall = true;
      allowSFTP = false;
      extraConfig = ''
        AllowTcpForwarding yes
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
        PubkeyAuthOptions verify-required
      '';
    };
  };

  networking.hostName = "a4blue-nixos-iso";

  environment.systemPackages = with pkgs; [
    parted
    gptfdisk
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
