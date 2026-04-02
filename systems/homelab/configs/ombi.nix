{config, ...}: let
  serviceDomain = "ombi.home.a4blue.me";
  dataDir = "/var/lib/ombi";
in {
  ####
  # Main Config
  ####
  services.ombi = {
    enable = true;
    inherit dataDir;
  };
  ####
  # Nginx
  ####
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    extraConfig = ''
      client_max_body_size 512M;
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.ombi.port}";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
      '';
    };
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = config.services.ombi.dataDir;
        mode = "0740";
        user = "ombi";
        group = "ombi";
      }
    ];
  };
}
