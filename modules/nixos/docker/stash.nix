{config, ...}: let
  servicePort = 9999;
  serviceDomain = "stash.home.a4blue.me";
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
    autoStart = true;
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

  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}/";
      extraConfig = ''
        client_max_body_size 512M;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Protocol $scheme;
      '';
    };
  };

  systemd.services."${config.virtualisation.oci-containers.containers."stash-container".serviceName}" = {
    after = ["LargeMedia.mount" "bcachefs-large-media-mount.service"];
    serviceConfig = {RestartSec = 5;};
  };

  networking.firewall.allowedTCPPorts = [servicePort];
}
