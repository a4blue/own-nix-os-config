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
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
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
