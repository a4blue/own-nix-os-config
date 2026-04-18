{
  config,
  lib,
  ...
}: let
  serviceDomain = "seerr.home.a4blue.me";
  dataDir = "/var/lib/seerr";
in {
  ####
  # Main Config
  ####
  services.seerr = {
    enable = true;
    configDir = dataDir;
  };
  systemd.services.seerr = {
    serviceConfig = {
      PrivateMounts = lib.mkForce false;
    };
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
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.seerr.port}";
      extraConfig = ''
        allow 192.168.178.0/24;
        allow fd00:0:3ea6:2fff:0:0:0:0/64;
        deny all;
      '';
    };
  };
  ####
  # Impermanence
  ####
  #environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
  #  directories = [
  #    {
  #      directory = "/var/lib/private/seerr";
  #      mode = "0755";
  #      user = "nobody";
  #      group = "nogroup";
  #    }
  #  ];
  #};
}
