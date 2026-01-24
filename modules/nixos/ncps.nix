{
  config,
  lib,
  ...
}: {
  services.ncps = {
    enable = true;
    cache.hostName = "ncps.homelab.internal";
    server.addr = "192.168.178.65:8501";
    cache.upstream = {
      urls = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
      ];
      publicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      "/var/lib/ncps"
    ];
  };
  networking.firewall.allowedTCPPorts = [8501];
  networking.firewall.allowedUDPPorts = [8501];
}
