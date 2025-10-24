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

    ./hardware-configuration.nix

    #./configs

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
    #../../modules/nixos/stalwart.nix
    #../../modules/nixos/prometheus.nix
    #../../modules/nixos/grafana.nix

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
    nameservers = ["127.0.0.1" "8.8.8.8"];
  };

  zramSwap.enable = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.intel-gpu-tools.enable = true;

  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 10;
    };
    extraModprobeConfig = ''
      # This should fix "stuttering" external HDD
      # https://forum.level1techs.com/t/external-usb-3-hdd-fails-to-transfer-files-on-linux/153056/15
      # https://bbs.archlinux.org/viewtopic.php?id=284971
      # seems like the core issue is a bad usb host, switching to new device soon
      #options usb-storage quirks=174c:1356:u
      options usbcore autosuspend=-1
    '';
    kernelPackages = pkgs.linuxPackages_6_17;
    supportedFilesystems = ["bcachefs"];

    # Driver needed for Remote disk Unlocking
    initrd = {
      availableKernelModules = ["r8169"];
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
    };
  };

  environment.systemPackages = [
  ];
  nixpkgs.config.permittedInsecurePackages = [
  ];
}
