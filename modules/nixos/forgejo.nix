{config, ...}: let
  servicePort = 38003;
  serviceDomain = "forgejo.homelab.internal";
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
      #service.DISABLE_REGISTRATION = true;
    };
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    #forceSSL = true;
    sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
    sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
    extraConfig = ''
      ssl_stapling off;
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}/";
      extraConfig = ''
        client_max_body_size 512M;
        deny 192.168.178.1;
        allow 192.168.178.0/24;
        deny all;
      '';
    };
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
