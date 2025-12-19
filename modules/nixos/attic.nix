{config, ...}: {
  services.atticd = {
    enable = true;
    environmentFile = "/nix/secret/attic/environmentFile";
    settings = {
      listen = "192.168.178.65:8085";
      storage = {
        type = "local";
        path = "/var/lib/atticd-storage";
      };

      jwt = {};
      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      "/var/lib/atticd-storage"
    ];
  };

  networking.firewall.allowedTCPPorts = [8085];
  networking.firewall.allowedUDPPorts = [8085];
}
