{config, ...}: {
  imports = [
    ./nginx.nix
    ./mysql.nix
  ];
  sops.secrets.photoprism_password = {
    owner = "photoprism";
    group = "photoprism";
  };
  services.photoprism = {
    enable = true;
    passwordFile = config.sops.secrets.photoprism_password.path;
    storagePath = "/var/lib/photoprism";
    originalsPath = "/var/lib/photoprism/originals";
    importPath = "/var/lib/photoprism/import";
    port = 2342;
    address = "localhost";
    settings = {
      PHOTOPRISM_ADMIN_USER = "root";
      PHOTOPRISM_DEFAULT_LOCALE = "de";
      PHOTOPRISM_SITE_URL = "https://homelab.armadillo-snake.ts.net/photoprism";
      PHOTOPRISM_TRUSTED_PROXY = "127.0.0.1";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
    };
  };

  services.nginx.virtualHosts."homelab.armadillo-snake.ts.net".locations."/photoprism" = {
    recommendedProxySettings = true;
    proxyPass = "http://localhost:2342";
    proxyWebsockets = true;
    extraConfig = ''
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_buffering off;
      client_max_body_size 500m;
    '';
  };

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
        directory = "/var/lib/photoprism";
        mode = "0777";
        user = "photoprism";
        group = "photoprism";
      }
    ];
  };
}
