{
  config,
  pkgs,
  lib,
  ...
}: let
  servicePort = 3000;
  serviceDomain = "grafana.homelab.internal";
in {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = servicePort;
        enforce_domain = true;
        enable_gzip = true;
        domain = serviceDomain;
      };
      analytics.reporting_enabled = false;
    };
    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        }
      ];
    };
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
    sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
    extraConfig = ''
      ssl_stapling off;
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        deny 192.168.178.1;
        allow 192.168.178.0/24;
        deny all;
        proxy_buffering off;
      '';
    };
  };
}
