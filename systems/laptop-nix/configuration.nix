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
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/hardening.nix
    ../../modules/nixos/home-manager-base.nix
    ../../modules/nixos/home-wifi.nix

    ../../configs/common
  ];

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
    htop
    ncdu
    qdirstat
    pynitrokey
    nerd-fonts.fira-code
    nerd-fonts.terminess-ttf
    fira-code
    vulkan-tools
    virtualgl
    libva-utils
    ffmpeg
    mangohud
    protonup-qt
    lutris
    bottles
    heroic
    protontricks
  ];
  fonts.packages = [pkgs.nerd-fonts.fira-code];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;

  hardware.bluetooth.enable = true;

  programs.fuse.userAllowOther = true;
  programs.steam.enable = true;
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

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
    "fluffychat-linux-1.25.1"
  ];

  home-manager.users = {
    a4blue = {
      imports = [
        ./../../configs/home-manager/a4blue
      ];
      home.packages = with pkgs; [
        proton-pass
        joplin-desktop
        element-desktop
        simplex-chat-desktop
        signal-desktop
        libreoffice-qt6-fresh
        vlc
        mpv
        fluffychat
        #kdePackages.neochat
      ];
      # Enable GUI Programs
      programs.firefox.enable = true;
      programs.vscode.enable = true;
      programs.alacritty.enable = true;
      programs.wezterm.enable = true;
      programs.ssh.enable = true;
      programs.joshuto.enable = true;
    };
  };
  home-manager.backupFileExtension = "hm-backup";

  boot.kernelPackages = pkgs.linuxPackages_6_14;
  boot.supportedFilesystems = ["bcachefs"];

  # Driver needed for Remote disk Unlocking
  boot.initrd.availableKernelModules = ["r8169"];
  boot.initrd.systemd.enable = true;

  boot.initrd.systemd.emergencyAccess = true;

  services.printing.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      #pkgs.rocmPackages.clr.icd
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
  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
      ];
    };
  };
}
