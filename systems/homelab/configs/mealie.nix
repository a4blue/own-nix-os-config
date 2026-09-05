{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "mealie.home.a4blue.me";
in {
  services = {
    ####
    # Main Config
    ####
    mealie = {
      enable = true;
      listenAddress = "127.0.0.1";
      database.createLocally = true;
      settings = {
        ALLOW_SIGNUP = "false";
        BASE_URL = serviceDomain;
      };
    };
    ####
    # Nginx
    ####
    nginx.virtualHosts."${serviceDomain}" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      extraConfig = ''
        client_max_body_size 512M;
        add_header X-Content-Type-Options "nosniff";
      '';
      locations."/" = {
        recommendedProxySettings = true;
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.mealie.port}";
      };
    };
  };
}
