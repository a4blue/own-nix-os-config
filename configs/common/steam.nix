{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
lib.mkIf config.programs.steam.enable {
  environment.systemPackages = with pkgs; [
    steamtinkerlaunch
  ];

  programs = {
    steam = {
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [proton-ge-bin steamtinkerlaunch];
    };
    gamemode.enable = true;
    nix-ld = {
      enable = true;
    };
    java.enable = true;
  };
}
