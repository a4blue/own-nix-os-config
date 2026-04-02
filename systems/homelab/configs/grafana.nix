{config, ...}: let
  serviceDomain = "grafana.home.a4blue.me";
  dataDir = "/var/lib/grafana";
in {
  services.grafana = {
    enable = true;
    security.secretKey = "SW2YcwTIb9zpOOhoPsMm";
    dataDir = dataDir;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        enforce_domain = true;
        enable_gzip = true;
        domain = serviceDomain;
      };

      analytics.reporting_enabled = false;
    };
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    extraConfig = ''
      client_max_body_size 512M;
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
        allow 192.168.178.0/24;
        allow fd00:0:3ea6:2fff:0:0:0:0/64;
        deny all;
      '';
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = config.services.grafana.dataDir;
        mode = "0740";
        user = "grafana";
        group = "grafana";
      }
    ];
  };
}
