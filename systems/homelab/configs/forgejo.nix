{config, ...}: let
  serviceDomain = "forgejo.home.a4blue.me";
  dataDir = "/var/lib/forgejo";
in {
  ####
  # Main Config
  ####
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    stateDir = dataDir;
    settings = {
      server = {
        DOMAIN = serviceDomain;
        ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}";
      };
      service.DISABLE_REGISTRATION = true;
    };
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
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";
      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = config.services.forgejo.stateDir;
        mode = "0740";
        user = "forgejo";
        group = "forgejo";
      }
    ];
  };
}
