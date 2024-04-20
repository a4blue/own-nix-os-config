{config, ...}: {
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "homelab.armadillo-snake.ts.net";
        ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}/forgejo/";
        HTTP_PORT = 3001;
      };
      #service.DISABLE_REGISTRATION = true;
    };
  };
  services.nginx.virtualHosts."homelab.armadillo-snake.ts.net".locations."/forgejo" = {
    recommendedProxySettings = true;
    proxyPass = "http://localhost:3001";
    extraConfig = ''
      client_max_body_size 512M;
    '';
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/forgejo";
        mode = "0740";
        user = "forgejo";
        group = "forgejo";
      }
    ];
  };
}
