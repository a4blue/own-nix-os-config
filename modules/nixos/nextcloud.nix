{
  config,
  pkgs,
  ...
}: {
  sops.secrets.nextcloud-admin-pass = {};
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
    ];
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    {
      addr = "127.0.0.1";
      port = 8080;
    }
  ];
}
