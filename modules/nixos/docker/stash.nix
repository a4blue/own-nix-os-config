{config, ...}: let
  servicePort = 9999;
  # Not used yet
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
    #user = "a4blue:users";
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
    sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
    sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
    extraConfig = ''
      ssl_stapling off;
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}/";
      extraConfig = ''
        client_max_body_size 512M;
        '';
    };
  };

  systemd.services."${config.virtualisation.oci-containers.containers."stash-container".serviceName}".after = ["LargeMedia.mount"];

  networking.firewall.allowedTCPPorts = [servicePort];
}
