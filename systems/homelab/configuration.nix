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

    # base stuff
    ../../modules/nixos/base.nix
    ../../modules/nixos/remote-disk-unlocking.nix
    ../../modules/nixos/impermanence.nix
    #../../modules/nixos/re-create-root.nix
    ../../modules/nixos/hardening.nix
    ../../modules/nixos/home-manager-base.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/docker/stash.nix

    # web services
    #../../modules/nixos/homepage-dashboard.nix
    ../../modules/nixos/paperless.nix
    ../../modules/nixos/nextcloud.nix
    ../../modules/nixos/borgbackup.nix
    #../../modules/nixos/jellyfin.nix
    ../../modules/nixos/forgejo.nix
    #../../modules/nixos/firefly-iii.nix
    # other services
    ../../modules/nixos/samba.nix
    ../../modules/nixos/blocky.nix
    ../../modules/nixos/fail2ban.nix
    #../../modules/nixos/clamav.nix
    ../../modules/nixos/dynv6.nix
    #../../modules/nixos/stalwart.nix
    ../../modules/nixos/recreate-root/options.nix
    ../../modules/nixos/prometheus.nix
    ../../modules/nixos/grafana.nix

    ../../configs/common
  ];

  modules.recreate-root.enable = true;
  modules.recreate-root.systemd-device-bind = "dev-nvme0n1p3.device";

  programs.fuse.userAllowOther = true;
  networking.hostName = "homelab";
  zramSwap.enable = true;

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  services = {
    openssh.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
  };

  networking.networkmanager.enable = true;

  # TODO
  # Extra Module, maybe use it for something ?
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true;

  home-manager.users = {
    a4blue = {
      imports = [
        ./../../configs/home-manager/a4blue
        ./../../modules/home-manager/persistence.nix
        inputs.impermanence.nixosModules.home-manager.impermanence
      ];
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_6_14;
  boot.supportedFilesystems = ["bcachefs"];

  # Driver needed for Remote disk Unlocking
  boot.initrd.availableKernelModules = ["r8169"];
  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.emergencyAccess = true;

  # Network DNS Fallback
  networking.nameservers = ["127.0.0.1" "8.8.8.8"];
}
