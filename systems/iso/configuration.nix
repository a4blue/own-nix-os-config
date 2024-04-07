{pkgs, ...}: {
  imports = [
    ./../../modules/nixos/system-packages.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb2erO3CjSDZdQNfU720I4vxt1K5XzECQ/ncROZmA2X"
    ];
  };

  boot.supportedFilesystems = ["bcachefs"];
  #boot.kernelPackages = pkgs.linuxPackages_latest;

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
    bcachefs
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
