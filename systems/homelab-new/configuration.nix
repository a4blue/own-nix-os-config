{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    inputs.lanzaboote.nixosModules.lanzaboote

    ./hardware-configuration.nix

    ./configs

    # base stuff
    ../../modules/nixos/base.nix
    ../../modules/nixos/remote-disk-unlocking.nix
    ../../modules/nixos/impermanence.nix
    ../../modules/nixos/hardening.nix
    ../../modules/nixos/home-manager-base.nix
    #../../modules/nixos/docker.nix
    #../../modules/nixos/docker/stash.nix

    # web services
    #../../modules/nixos/nextcloud.nix
    #../../modules/nixos/borgbackup.nix
    #../../modules/nixos/jellyfin.nix
    #../../modules/nixos/forgejo.nix
    # other services
    #../../modules/nixos/samba.nix
    #../../modules/nixos/blocky.nix
    #../../modules/nixos/fail2ban.nix
    #../../modules/nixos/dynv6.nix

    ../../configs/common
  ];
  modules.impermanenceExtra.enabled = true;
  modules.impermanenceExtra.defaultPath = "/nix/persistent";

  sops = {
    age.sshKeyPaths = ["/nix/secret/initrd/sops_key"];
  };

  programs.fuse.userAllowOther = true;
  networking = {
    hostName = "homelab-new";
    networkmanager.enable = true;
    # Network DNS Fallback
    #nameservers = ["127.0.0.1" "8.8.8.8"];
  };

  zramSwap.enable = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.intel-gpu-tools.enable = true;

  boot = {
    tmp.cleanOnBoot = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      timeout = 10;
    };
    extraModprobeConfig = ''
      options usbcore autosuspend=-1
    '';
    kernelPackages = pkgs.linuxPackages_6_17;
    supportedFilesystems = ["bcachefs"];

    initrd = {
      systemd.enable = true;
      systemd.emergencyAccess = true;
    };
  };

  services = {
    openssh.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
  };

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };
  home-manager.users = {
    a4blue = {
      imports = [
        ./../../configs/home-manager/a4blue
        ./../../modules/home-manager/persistence.nix
        inputs.impermanence.nixosModules.home-manager.impermanence
      ];
      modules = {
        impermanenceExtra = {
          enabled = true;
          defaultPath = "/nix/persistent/home/a4blue";
        };
      };
    };
  };
  home-manager.backupFileExtension = "hm-backup";

  environment.systemPackages = [
    pkgs.sbctl
  ];
  nixpkgs.config.permittedInsecurePackages = [
  ];
}
