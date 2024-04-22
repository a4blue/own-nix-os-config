{config, ...}: let
  servicePort = 38002;
in {
  #imports = [
  #  ./nginx.nix
  #  ./mysql.nix
  #];
  # Photoprism sadly runs as root
  #sops.secrets.photoprism_password = {
  #owner = "photoprism";
  #group = "photoprism";
  # ugly
  #  mode = "0777";
  #};
  #services.photoprism = {
  #  enable = true;
  #  passwordFile = config.sops.secrets.photoprism_password.path;
  #  storagePath = "/var/lib/photoprism-storage";
  #  originalsPath = "${config.services.photoprism.storagePath}/originals";
  #  importPath = "${config.services.photoprism.storagePath}/import";
  #  port = servicePort;
  #  address = "192.168.178.64";
  #  settings = {
  #    PHOTOPRISM_DEFAULT_LOCALE = "de";
  #PHOTOPRISM_SITE_URL = "https://homelab.armadillo-snake.ts.net/photoprism";
  #    PHOTOPRISM_SITE_URL = "http://192.168.178.64:${builtins.toString servicePort}";
  #PHOTOPRISM_TRUSTED_PROXY = "127.0.0.1";
  #    PHOTOPRISM_DATABASE_DRIVER = "mysql";
  #    PHOTOPRISM_DATABASE_NAME = "photoprism";
  #    PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
  #    PHOTOPRISM_DATABASE_USER = "photoprism";
  #    PHOTOPRISM_CONFIG_PATH = "${config.services.photoprism.storagePath}/config";
  #    PHOTOPRISM_DEBUG = "";
  #  };
  #};

  #networking.firewall.allowedTCPPorts = [servicePort];

  #services.nginx.virtualHosts."homelab.armadillo-snake.ts.net".locations."/photoprism" = {
  #  recommendedProxySettings = true;
  #  proxyPass = "http://localhost:${builtins.toString servicePort}";
  #  proxyWebsockets = true;
  #  extraConfig = ''
  #    proxy_buffering off;
  #    client_max_body_size 500m;
  #    proxy_set_header Upgrade $http_upgrade;
  #    proxy_set_header Connection "upgrade";
  #  '';
  #};

  services.mysql = {
    ensureDatabases = ["photoprism"];
    ensureUsers = [
      {
        name = "photoprism";
        ensurePermissions = {
          "photoprism.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "${config.services.photoprism.storagePath}";
        mode = "0777";
        user = "photoprism";
        group = "photoprism";
      }
    ];
  };
}
