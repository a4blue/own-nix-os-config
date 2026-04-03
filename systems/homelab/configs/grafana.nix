{config, ...}: let
  serviceDomain = "grafana.home.a4blue.me";
  dataDir = "/var/lib/grafana";
in {
  ####
  # Main Config
  ####
  services.grafana = {
    enable = true;
    #declarativePlugins = with pkgs.grafanaPlugins; [ ... ];
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          isDefault = true;
          editable = false;
        }
      ];
    };
    inherit dataDir;
    settings = {
      security.secret_key = "$__file{${config.sops.secrets.grafanaSecretKey.path}}";
      server = {
        http_addr = "127.0.0.1";
        enforce_domain = true;
        enable_gzip = true;
        domain = serviceDomain;
      };

      analytics.reporting_enabled = false;
    };
  };
  ####
  # Secrets
  ####
  sops.secrets.grafanaSecretKey = {
    owner = "grafana";
    group = "grafana";
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
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.grafana.settings.server.http_port}";
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
