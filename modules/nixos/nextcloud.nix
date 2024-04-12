{
  config,
  pkgs,
  ...
}: {
  sops.secrets.nextcloud-admin-pass = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    https = true;
    hostName = "localhost";
    configureRedis = true;
    database.createLocally = true;
    package = pkgs.nextcloud28;
    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
    };
    settings = let
      prot = "http";
      host = "homelab.armadillo-snake.ts.net";
      dir = "/nextcloud";
    in {
      overwriteprotocol = prot;
      overwritehost = host;
      overwritewebroot = dir;
      overwrite.cli.url = "${prot}://${host}${dir}/";
      htaccess.RewriteBase = dir;
    };
  };

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/nextcloud"
      "/var/lib/redis-nextcloud"
    ];
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    {
      addr = "127.0.0.1";
      port = 8080;
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
        proxy_pass http://localhost:8080/; # tailing / is important!
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_redirect off;
      '';
    };
  };
}
