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
      enable = true;
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
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.open-webui.port}";
      };
    };
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/${config.services.open-webui.stateDir}";
        mode = "0740";
        user = "sabnzbd";
        group = "sabnzbd";
      }
    ];
  };
}
