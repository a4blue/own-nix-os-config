{
  config,
  pkgs,
  ...
}: let
  servicePort = 38000;
in {
  imports = [
    ./nginx.nix
  ];
  sops.secrets.nextcloud-admin-pass = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    https = true;
    hostName = "localhost";
    configureRedis = true;
    caching.redis = true;
    database.createLocally = true;
    package = pkgs.nextcloud28;
    appstoreEnable = false;
    phpOptions."opcache.interned_strings_buffer" = "32";
    maxUploadSize = "8G";
    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      # List of apps we want to install and are already packaged in
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
      inherit bookmarks calendar contacts mail notes tasks previewgenerator maps memories;

      recognize = pkgs.fetchNextcloudApp {
        url = "https://github.com/nextcloud/recognize/releases/download/v6.1.1/recognize-6.1.1.tar.gz";
        sha256 = "sha256-ziUc4J2y1lW1BwygwOKedOWbeAnPpBDwT9wh35R0MYk=";
        license = "agpl3Plus";
        appVersion = "6.1.1";
        description = "👁 👂 Smart media tagging for Nextcloud: recognizes faces, objects, landscapes, music genres";
        homepage = "https://apps.nextcloud.com/apps/recognize";
        appName = "recognize";
      };
    };

    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
    };
    settings = let
      prot = "https";
      host = "homelab.armadillo-snake.ts.net";
      dir = "/nextcloud";
    in {
      overwriteprotocol = prot;
      overwritehost = host;
      overwritewebroot = dir;
      overwrite.cli.url = "${prot}://${host}${dir}/";
      htaccess.RewriteBase = dir;
      default_phone_region = "DE";
      maintenance_window_start = 3;
      log_type = "file";
      loglevel = 1;
    };
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    {
      addr = "127.0.0.1";
      port = servicePort;
    }
  ];

  services.nginx.virtualHosts."homelab.armadillo-snake.ts.net" = {
    locations."^~ /.well-known" = {
      priority = 9000;
      extraConfig = ''
        absolute_redirect off;
        location ~ ^/\\.well-known/(?:carddav|caldav)$ {
          return 301 /nextcloud/remote.php/dav;
        }
        location ~ ^/\\.well-known/host-meta(?:\\.json)?$ {
          return 301 /nextcloud/public.php?service=host-meta-json;
        }
        location ~ ^/\\.well-known/(?!acme-challenge|pki-validation) {
          return 301 /nextcloud/index.php$request_uri;
        }
        try_files $uri $uri/ =404;
      '';
    };
    locations."/nextcloud/" = {
      priority = 9999;
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_set_header X-Forwarded-Proto http;
        proxy_pass http://localhost:${builtins.toString servicePort}/; # tailing / is important!
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_redirect off;
        client_max_body_size 9000m;
      '';
    };
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/nextcloud";
        mode = "0740";
        user = "nextcloud";
        group = "nextcloud";
      }
      {
        directory = "/var/lib/redis-nextcloud";
        mode = "0740";
        user = "redis-nextcloud";
        group = "redis-nextcloud";
      }
    ];
  };
}
