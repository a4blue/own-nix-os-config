{config, ...}: let
  servicePort = 9999;
  # Not used yet
  serviceDomain = "stash.homelab.internal";
in {
  imports = [
    ../docker.nix
  ];

  virtualisation.oci-containers.containers."stash-container" = {
    image = "stashapp/stash:latest";
    ports = ["${builtins.toString servicePort}:9999"];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/stash/config:/root/.stash"
      "/LargeMedia/smb/Porn:/data"
      "/var/lib/stash/metadata:/metadata"
      "/var/lib/stash/cache:/cache"
      "/var/lib/stash/blobs:/blobs"
      "/LargeMedia/stash_generated:/generated"
    ];
    environment = {
      STASH_STASH = "/data/";
      STASH_GENERATED = "/generated/";
      STASH_METADATA = "/metadata/";
      STASH_CACHE = "/cache/";
      STASH_PORT = "9999";
    };
    extraOptions = ["--device=/dev/dri/renderD128"];
    #user = "a4blue:users";
    autoStart = false;
  };

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/stash";
        mode = "2740";
        user = "a4blue";
        group = "users";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [servicePort];
}
