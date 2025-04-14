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
    gparted
    uutils-coreutils
    rsync
    ncdu
    qdirstat
    pynitrokey
    virtualgl
    libva-utils
    ffmpeg
    mangohud
    protonup-qt
    lutris
    bottles
    heroic
    protontricks
    lact
  ];
  fonts.packages = [pkgs.nerd-fonts.fira-code pkgs.nerd-fonts.terminess-ttf];

  programs = {
    fuse.userAllowOther = true;
    steam.enable = true;
  };
  networking.hostName = "laptop-nix";

  zramSwap.enable = true;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 10;
    };
    kernelPackages = pkgs.linuxPackages_6_14;
    supportedFilesystems = ["bcachefs"];

    initrd = {
      systemd.enable = true;
      systemd.emergencyAccess = true;
    };
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      defaultSession = "plasma";
      sddm.wayland.enable = true;
      sddm.enable = true;
    };
    xserver.enable = true;
    printing.enable = true;
    openssh.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      wireplumber.extraConfig."10-bluez" = {
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
    };
  };

  networking.networkmanager.enable = true;

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true;
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
    "fluffychat-linux-1.25.1"
  ];

  home-manager.users = {
    a4blue = {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "video/x-matroska" = "vlc.desktop";
        };
      };
      imports = [
        ./../../configs/home-manager/a4blue
      ];
      home.packages = with pkgs; [
        proton-pass
        joplin-desktop
        element-desktop
        simplex-chat-desktop
        signal-desktop-bin
        libreoffice-qt6-fresh
        vlc
        mpv
        fluffychat
        handbrake
      ];
      # Enable GUI Programs
      programs = {
        firefox.enable = true;
        vscode.enable = true;
        alacritty.enable = true;
        wezterm.enable = true;

        joshuto.enable = true;
        ghostty.enable = true;

        ssh = {
          enable = true;
          matchBlocks."homelab"
          .extraOptions."IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
          matchBlocks."homelab-unlock"
          .extraOptions."IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
        };
      };
    };
  };
  home-manager.backupFileExtension = "hm-backup";

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [
        pkgs.amdvlk
      ];
      extraPackages32 = [
        pkgs.driversi686Linux.amdvlk
      ];
    };
    amdgpu = {
      amdvlk.enable = true;
      amdvlk.support32Bit.enable = true;
      initrd.enable = true;
      opencl.enable = true;
    };
    xpadneo.enable = true;
    bluetooth.enable = true;
  };

  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

  security.rtkit.enable = true;
}
