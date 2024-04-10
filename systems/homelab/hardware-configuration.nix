# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "ums_realtek" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  #fileSystems."/" = {
  #  device = "none";
  #  fsType = "tmpfs";
  #  options = ["defaults" "size=4G" "mode=0755"];
  #};

  fileSystems."/" = {
    device = "/dev/nvme0n1p3";
    fsType = "bcachefs";
    options = ["compression=zstd"];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  #fileSystems."/persistent" = {
  #  device = "/dev/nvme0n1p3";
  #  neededForBoot = true;
  #  fsType = "bcachefs";
  #  options = ["X-mount.subdir=persistent"];
  #};

  #fileSystems."/nix" = {
  #  device = "/dev/nvme0n1p3";
  #  fsType = "bcachefs";
  #  options = ["X-mount.subdir=nix" "compression=zstd"];
  #  neededForBoot = true;
  #};

  swapDevices = [
    {
      device = "/dev/nvme0n1p2";
      randomEncryption.enable = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
