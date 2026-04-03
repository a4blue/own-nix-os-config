{config, ...}: let
  serviceDomain = "start.home.a4blue.me";
  dataDir = "/var/lib/homarr";
in {
  ####
  # Secrets
  ####
  sops.secrets."homarrEnv" = {
    owner = "nobody";
    group = "nogroup";
    mode = "0777";
  };
  ####
  # Main Config
  ####
  modules.homarr.enable = true;
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = dataDir;
        mode = "0777";
        user = "nobody";
        group = "nogroup";
      }
    ];
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
      proxyPass = "http://127.0.0.1:${builtins.toString config.modules.homarr.port}";
    };
  };
}
