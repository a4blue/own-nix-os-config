{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "webui.home.a4blue.me";
in {
  services = {
    ####
    # Main Config
    ####
    open-webui = {
      # TODO enable after fix
      enable = false;
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
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.open-webui.port}";
      };
    };
  };
}
