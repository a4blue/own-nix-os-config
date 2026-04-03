{
  config,
  lib,
  ...
}: let
  serviceDomain = "dashdot.home.a4blue.me";
in {
  ####
  # Main Config
  ####
  modules.dashdot.enable = true;
  ####
  # Nginx
  ####
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.modules.dashdot.port}";
    };
  };
}
