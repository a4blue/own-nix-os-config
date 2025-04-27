{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
lib.mkIf config.programs.steam.enable {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  programs = {
    steam = {
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    nix-ld = {
      enable = true;
    };
    java.enable = true;
  };
}
