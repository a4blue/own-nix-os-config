{config, ...}: {
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "homelab.armadillo-snake.ts.net";
        ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}/forgejo/";
        HTTP_PORT = 3000;
      };
      #service.DISABLE_REGISTRATION = true;
    };
  };
  services.nginx.virtualHosts."homelab.armadillo-snake.ts.net".locations."/forgejo" = {
    recommendedProxySettings = true;
    proxyPass = "http://localhost:3000";
    extraConfig = ''
      client_max_body_size 512M;
    '';
  };
}
