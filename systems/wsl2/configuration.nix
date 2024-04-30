{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  system.stateVersion = "24.05"; # Did you read the comment?
}
