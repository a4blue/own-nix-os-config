{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "auth.home.a4blue.me";
in {
  services = {
    ####
    # Main Config
    ####
    keycloak = {
      enable = true;
      settings = {
        hostname = "https://${serviceDomain}";
        proxy-headers = "xforwarded";
        http-enabled = true;
        http-host = "127.0.0.1";
        http-management-health-enabled = true;
        http-management-port = 9000;
        cache-metrics-histograms-enabled = true;
        metrics-enabled = true;
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
    ####
    # Postgres
    ####
    postgresql = {
      ensureDatabases = ["keycloak"];
      ensureUsers = [
        {
          name = "keycloak";
          ensureDBOwnership = true;
        }
      ];
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
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.keycloak.settings.http-port}";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_buffer_size     128k;
          proxy_buffers         4 256k;
          proxy_busy_buffers_size 256k;
        '';
      };
    };
    ####
    # Prometheus
    ####
    prometheus.scrapeConfigs = [
      {
        job_name = "jellyfin";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.keycloak.settings.http-management-port}/metrics"
            ];
          }
        ];
      }
    ];
  };
}
