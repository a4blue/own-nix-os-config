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
    inputs.impermanence.nixosModules.impermanence

    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/hardening.nix
    ../../modules/nixos/home-manager-base.nix

    ../../configs/common
  ];

  modules = {
    impermanenceExtra.enabled = true;
    impermanenceExtra.defaultPath = "/nix/persistent";
    sabnzbd.enable = true;
    desktopAudio.enable = true;
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    # Hide these mounts from the sidebar of file managers
    hideMounts = true;

    directories = [
      "/var/log"
      "/var/lib"
      # Persist non-declarative Network Connections
      "/etc/NetworkManager/system-connections"
      # Following will need a cleanup at start
      "/tmp"
      "/var/tmp"
      "/var/cache"
    ];

    files = [
      "/etc/machine-id"
    ];
  };
  sops = {
    age.sshKeyPaths = ["/nix/secret/initrd/sops_key"];
  };
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
    virt-manager.enable = true;
    firejail.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
  };
  networking = {
    hostName = "desktop-nix";
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
    libvirtd.enable = true;
  };

  zramSwap.enable = true;

  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
      timeout = 10;
    };
    kernelParams = [
      # Enable overclocking
      #"amdgpu.ppfeaturemask=0xffffffff"
      # Enable additional Video output during boot
      "video=DP-1:1920x1080@60"
      "video=DP-2:1920x1080@60"
      "video=DP-3:1920x1080@60"
      "video=HDMI-A-1:1920x1080@60"
    ];
    kernelPackages = pkgs.linuxPackages_6_16;
    supportedFilesystems = ["bcachefs"];

    initrd = {
      systemd.enable = true;
      systemd.emergencyAccess = true;
    };
  };

  services = {
    udev.packages = [pkgs.nitrokey-udev-rules];
    flatpak.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager = {
      defaultSession = "plasma";
      sddm.wayland.enable = true;
      sddm.enable = true;
    };
    xserver.enable = true;
    printing.enable = true;
    #openssh.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    wg-netmanager.enable = true;
  };

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true;
    };
  };

  users.users.a4blue.extraGroups = ["dialout" "podman" "gamemode" "libvirtd"];

  home-manager.users = {
    a4blue = {
      imports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.plasma-manager.homeModules.plasma-manager
        ../../configs/home-manager/a4blue
        ./configs/home-manager/impermanence.nix
        ./configs/home-manager/plasma.nix
        ./configs/home-manager/tor.nix
      ];

      home.persistence."${config.home-manager.users.a4blue.modules.impermanenceExtra.defaultPath}" = {
        directories = [
          ".sabnzbd"
        ];
      };

      modules = {
        impermanenceExtra = {
          enabled = true;
          defaultPath = "/nix/persistent/home/a4blue";
        };
        gaming.enable = true;
        graphicalApps.enable = true;
      };

      home.packages = with pkgs; [
        kdePackages.krdc
      ];
      services.gpg-agent.enable = true;
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
