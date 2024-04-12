{config, ...}: {
  services.nextcloud = {
    enable = true;
    https = true;
    hostName = "homelab.armadillo-snake.ts.net/nextcloud";
    configureRedis = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
    };
    settings = let
      prot = "http";
      host = "127.0.0.1";
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
