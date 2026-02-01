{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "keycloak.home.a4blue.me";
  servicePort = 38080;
in {
  services = {
    keycloak = {
      enable = true;
      settings = {
        hostname = serviceDomain;
        http-port = 38080;
        proxy-headers = "forwarded";
        http-enabled = true;
        http-host = "127.0.0.1";
      };
      plugins = [
        pkgs.junixsocket-common
        pkgs.junixsocket-native-common
      ];
      database = {
        type = "postgresql";
        createLocally = false;
        host = "/run/postgresql";
      };
    };
    postgresql = {
      ensureDatabases = ["keycloak"];
      ensureUsers = [
        {
          name = "keycloak";
          ensureDBOwnership = true;
        }
      ];
    };
    nginx.virtualHosts."${serviceDomain}" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      extraConfig = ''
        client_max_body_size 20M;
        add_header X-Content-Type-Options "nosniff";
      '';
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
        extraConfig = ''
          proxy_set_header Host $host;
          allow 192.168.178.1/24;
          deny all;
        '';
      };
    };
  };
}
