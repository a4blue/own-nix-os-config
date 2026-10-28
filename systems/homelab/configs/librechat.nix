{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "librechat.home.a4blue.me";
in {
  sops.secrets = {
    "librechat/env" = {
      owner = config.services.librechat.user;
      group = config.services.librechat.group;
    };
  };
  services = {
    ####
    # Main Config
    ####
    librechat = {
      enable = true;
      enableLocalDB = true;
      credentialsFile = config.sops.secrets."librechat/env".path;
      # TODO enable it later
      meilisearch.enable = false;
    };

    ####
    # Nginx
    ####
    nginx.virtualHosts."${serviceDomain}" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      http2 = true;
      http3 = true;
      quic = true;
      extraConfig = ''
        client_max_body_size 512M;
        add_header X-Content-Type-Options "nosniff";
      '';
      locations."/" = {
        recommendedProxySettings = true;
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.librechat.env.PORT}";
      };
    };
  };
}
