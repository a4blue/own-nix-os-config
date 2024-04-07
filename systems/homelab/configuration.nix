# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/remote-disk-unlocking.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      bcachefs-update = super.bcachefs-tools.overrideAttrs (old: {
        version = "1.6.4";
        src = super.fetchFromGitHub {
          owner = "koverstreet";
          repo = "bcachefs-tools";
          rev = "v${self.version}";
          hash = "010182e79051fccbedc35aaa55dc67266ae3b3d0";
        };
      });
    })
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
    users = {
      a4blue = {
        imports = [
          ./../../modules/home-manager/base.nix
        ];
      };
    };
  };

  networking.hostName = "homelab";

  # Bcache support
  boot.supportedFilesystems = ["bcachefs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bcache remote unlock
  boot.initrd.systemd = let
    askPass = pkgs.writeShellScriptBin "bcachefs-askpass" ''
      keyctl link @u @s
      mkdir /sysroot
      until bcachefs mount /dev/nvme0n1p2 /nix
      do
        sleep  1
      done
    '';
  in {
    enable = true;
    initrdBin = with pkgs; [keyutils];
    storePaths = ["${askPass}/bin/bcachefs-askpass"];
    users.root.shell = "${askPass}/bin/bcachefs-askpass";
  };

  # Driver needed for Remote disk Unlocking
  boot.initrd.availableKernelModules = ["r8169"];

  # Network DNS Fallback
  networking.nameservers = ["8.8.8.8"];

  # Set your time zone.
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

  # backup user, will be removed later
  users.users.a4blue_backup = {
    isNormalUser = true;
    description = "Alexander Ratajczak";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  users.users.a4blue_backup.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb2erO3CjSDZdQNfU720I4vxt1K5XzECQ/ncROZmA2X a4blue"];

  system.stateVersion = "23.11";
}
