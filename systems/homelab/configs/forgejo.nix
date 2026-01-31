{config, ...}: let
  servicePort = 38003;
  serviceDomain = "forgejo.home.a4blue.me";
in {
  imports = [
    ./nginx.nix
    ./postgresql.nix
  ];
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = serviceDomain;
        ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}";
        HTTP_PORT = servicePort;
      };
      service.DISABLE_REGISTRATION = true;
    };
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    enableACME = true;
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
        directory = "/var/lib/forgejo";
        mode = "0740";
        user = "forgejo";
        group = "forgejo";
      }
    ];
  };
}
