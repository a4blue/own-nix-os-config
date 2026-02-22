{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "auth.home.a4blue.me";
  servicePort = 38080;
in {
  services = {
    keycloak = {
      enable = true;
      settings = {
        hostname = "https://${serviceDomain}";
        http-port = 38080;
        proxy-headers = "xforwarded";
        http-enabled = true;
        http-host = "127.0.0.1";
        http-management-health-enabled = true;
        http-management-port = 9000;
      };
      plugins = [
        pkgs.keycloak.plugins.junixsocket-common
        pkgs.keycloak.plugins.junixsocket-native-common
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
        client_max_body_size 512M;
        add_header X-Content-Type-Options "nosniff";
      '';
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };
      locations."/health" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:9000/health";
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };
    };
  };
}
