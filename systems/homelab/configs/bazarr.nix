{config, ...}: let
  servicePort = 65535;
  serviceDomain = "bazarr.home.a4blue.me";
in {
  services.bazarr.enable = true;
  services.bazarr.listenPort = servicePort;
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}/";
      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/bazarr";
        mode = "0740";
        user = "bazarr";
        group = "bazarr";
      }
    ];
  };
}
