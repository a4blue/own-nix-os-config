{config, ...}: let
  serviceDomain = "bazarr.home.a4blue.me";
  dataDir = "/var/lib/bazarr";
in {
  services.bazarr = {
    enable = true;
    dataDir = dataDir;
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.bazarr.listenPort}/";
      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
  };
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
