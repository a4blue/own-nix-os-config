{config, ...}: {
  services.ncps = {
    enable = true;
    cache.hostName = "ncps.homelab.internal";
    server.addr = "0.0.0.0:8501";
    upstream = {
      caches = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      publicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
