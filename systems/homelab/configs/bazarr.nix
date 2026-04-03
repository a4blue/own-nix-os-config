{config, ...}: let
  serviceDomain = "bazarr.home.a4blue.me";
  dataDir = "/var/lib/bazarr";
in {
  ####
  # Main Config
  ####
  services.bazarr = {
    enable = true;
    inherit dataDir;
  };
  ####
  # Nginx
  ####
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.bazarr.listenPort}";
    };
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = config.services.bazarr.dataDir;
        mode = "0740";
        user = "bazarr";
        group = "bazarr";
      }
    ];
  };
}
