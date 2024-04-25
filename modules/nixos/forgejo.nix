{config, ...}: let
  servicePort = 38003;
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
        DOMAIN = "forgejo.homelab.local";
        ROOT_URL = "http://${config.services.forgejo.settings.server.DOMAIN}";
        HTTP_PORT = servicePort;
      };
      #service.DISABLE_REGISTRATION = true;
    };
  };
  services.nginx.virtualHosts."forgejo.homelab.local".locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://localhost:${builtins.toString servicePort}/";
    extraConfig = ''
      client_max_body_size 512M;
      deny 192.168.178.1;
      allow 192.168.178.0/24;
      deny all;
    '';
  };

  environment.persistence."/persistent" = {
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
