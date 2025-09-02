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

    ../../configs/common
  ];

  environment.systemPackages = with pkgs; [
    gparted
    uutils-coreutils
    rsync
    ncdu
    qdirstat
    #pynitrokey
    virtualgl
    libva-utils
    ffmpeg
    lact
    podman-compose
    vulkan-tools
    nvtopPackages.amd
    fd
    gnupg
  ];
  fonts.packages = [pkgs.nerd-fonts.fira-code pkgs.nerd-fonts.terminess-ttf];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "unrar"
    ];

  programs = {
    fuse.userAllowOther = true;
    steam.enable = true;
    gnupg.agent.enable = true;
  };
  networking = {
    hostName = "laptop-nix";
    networkmanager.enable = true;
    firewall.allowedUDPPorts = [51820];
    wireguard = {
      # wireguard conf needs to be imperative for gui
      # due to deactivating the connection once its gone
      enable = true;
    };
  };

  virtualisation = {
    podman.enable = true;
  };

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
    kernelPackages = pkgs.linuxPackages_6_16;
    supportedFilesystems = ["bcachefs"];

    initrd = {
      systemd.enable = true;
      systemd.emergencyAccess = true;
    };
  };

  services = {
    udev.packages = [pkgs.nitrokey-udev-rules];
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
    wg-netmanager.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true;
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
    "fluffychat-linux-1.27.0"
  ];

  users.users.a4blue.extraGroups = ["dialout" "podman"];

  home-manager.users = {
    a4blue = {
      imports = [
        inputs.plasma-manager.homeModules.plasma-manager
        ./../../configs/home-manager/a4blue
        ../desktop/configs/home-manager/plasma.nix
      ];
      home.packages = with pkgs; [
      ];
      modules = {
        #impermanenceExtra = {
        #  enabled = true;
        #  defaultPath = "/nix/persistent/home/a4blue";
        #};
        gaming.enable = true;
        graphicalApps.enable = true;
      };
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
        };
      };
    };
  };
  home-manager.backupFileExtension = "hm-backup";

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu = {
      opencl.enable = true;
      overdrive.enable = true;
    };
    xpadneo.enable = true;
    bluetooth.enable = true;
    sane.enable = true;
  };

  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

  security.rtkit.enable = true;
}
