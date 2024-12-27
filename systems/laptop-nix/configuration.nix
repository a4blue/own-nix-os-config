# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    #inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    #../../modules/nixos/remote-disk-unlocking.nix
    #../../modules/nixos/impermanence.nix
    #../../modules/nixos/re-create-root.nix
    ../../modules/nixos/hardening.nix
    ../../modules/nixos/home-manager-base.nix
    ../../modules/nixos/home-wifi.nix
    #../../modules/nixos/docker.nix
    ./38c3-wifi.nix
  ];

  nix.settings.substituters = ["https://cache.nixos.sh"];
  nix.settings.connect-timeout = 5;
  environment.systemPackages = with pkgs; [
    parted
    gparted
    gptfdisk
    pciutils
    uutils-coreutils
    wget
    rsync
    git
    git-extras
    git-lfs
    firefox
    htop
    ncdu
    qdirstat
    pynitrokey
    nerd-fonts.fira-code
    nerd-fonts.terminess-ttf
    fira-code
    vulkan-tools
  ];
  fonts.packages = [pkgs.nerd-fonts.fira-code];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  programs.firefox.nativeMessagingHosts.packages = [pkgs.plasma6Packages.plasma-browser-integration];
  hardware.enableAllFirmware = true;

  programs.fuse.userAllowOther = true;
  networking.hostName = "laptop-nix";

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

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      #withJava = true;
      #withPrimus = true;
      #extraPkgs = pkgs: [ bumblebee glxinfo ];
    };
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };
  #programs.java.enable = true;
  programs.nix-ld = {
    enable = true;
    #libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
  };

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true;

  home-manager.users = {
    a4blue = {
      imports = [
        ./../../modules/home-manager/base.nix
        #./../../modules/home-manager/persistence.nix
      ];
      home.packages = with pkgs; [
        proton-pass
        joplin-desktop
        wezterm
        element-desktop
      ];
      programs.firefox = {
        enable = true;
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisableAccounts = true;
          DisableFirefoxAccounts = true;
          DisablePocket = true;
          DontCheckDefaultBrowser = true;
        };
      };
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.supportedFilesystems = ["bcachefs"];

  # Driver needed for Remote disk Unlocking
  boot.initrd.availableKernelModules = ["r8169"];
  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.emergencyAccess = true;

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

  services.printing.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
      pkgs.amdvlk
    ];
    extraPackages32 = [
      pkgs.driversi686Linux.amdvlk
    ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  system.stateVersion = "24.11";
}
