{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./../../modules/nixos/system-packages.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.supportedFilesystems.bcachefs = true;
  boot.supportedFilesystems.zfs = lib.mkForce false;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb2erO3CjSDZdQNfU720I4vxt1K5XzECQ/ncROZmA2X"
    ];
  };

  #boot.initrd.kernelModules = [ "wl" ];

  #boot.kernelModules = [ "kvm-intel" "wl" ];

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh = {
    enable = true;
  };

  networking.hostName = "a4blue-nixos-iso";

  environment.systemPackages = with pkgs; [
    parted
    ventoy
    gptfdisk
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  console.keyMap = "de";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
