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
    inputs.attic.nixosModules.atticd

    ./hardware-configuration.nix

    ./configs

    # base stuff
    ../../modules/nixos/base.nix
    ../../modules/nixos/impermanence.nix
    ../../modules/nixos/hardening.nix
    ../../modules/nixos/home-manager-base.nix
    ./configs/remote-disk-unlocking.nix
    ./configs/docker.nix

    # web services
    ./configs/nextcloud.nix
    ./configs/borgbackup.nix
    ./configs/jellyfin.nix
    ./configs/forgejo.nix
    ./configs/sabnzbd.nix
    ./configs/stash.nix
    # other services
    ./configs/samba.nix
    ./configs/blocky.nix
    ./configs/fail2ban.nix
    ./configs/dynv6.nix
    ./configs/acme.nix

    ./configs/attic.nix
    ./configs/ncps.nix
    ./configs/lldap.nix
    ./configs/authelia.nix

    ../../configs/common
  ];
  modules.impermanenceExtra.enabled = true;
  modules.impermanenceExtra.defaultPath = "/nix/persistent";

  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "unrar"
      ];
    allowUnfree = true;
    permittedInsecurePackages = [
    ];
  };

  sops = {
    age.sshKeyPaths = ["/nix/secret/initrd/sops_key"];
  };

  programs.fuse.userAllowOther = true;
  networking = {
    hostName = "homelab";
    networkmanager.enable = true;
    #nameservers = ["127.0.0.1" "192.168.178.1"];
  };

  zramSwap.enable = true;

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
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
      timeout = 10;
    };
    extraModprobeConfig = ''
      options usbcore autosuspend=-1
    '';
    kernelPackages = pkgs.linuxPackages_6_18;
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
    resolved.settings.Resolve.FallbackDNS = ["8.8.8.8" "1.1.1.1" "1.0.0.1" "8.8.4.4" "9.9.9.9" "149.112.112.112"];
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
      ];
      modules = {
        impermanenceExtra = {
          enabled = true;
          defaultPath = "/nix/persistent";
        };
      };
    };
  };
  home-manager.backupFileExtension = "hm-backup";

  environment.systemPackages = [
    pkgs.sbctl
  ];
}
