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
      package = pkgs.steam.override {
        #withJava = true;
        #withPrimus = true;
        #extraPkgs = pkgs: [ bumblebee glxinfo ];
      };
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    #programs.java.enable = true;
    nix-ld = {
      enable = true;
      #libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
    };
  };
}
