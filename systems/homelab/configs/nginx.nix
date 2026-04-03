{
  config,
  pkgs,
  ...
}: {
  ####
  # Main Config
  ####
  services.nginx = {
    package = pkgs.nginxMainline;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    statusPage = true;
    enable = true;
    virtualHosts = {
      # Public DynDNS
      "homelab.home.a4blue.me" = {
        forceSSL = true;
        useACMEHost = "home.a4blue.me";
        locations."/" = {
          root = "/var/www";
        };
      };
      # Default match
      "_" = {
        globalRedirect = "start.home.a4blue.me";
        default = true;
      };
    };
  };
  ####
  # Prometheus
  ####
  services.prometheus = {
    scrapeConfigs = [
      {
        job_name = "nginx";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.nginx.port}"
            ];
          }
        ];
      }
      {
        job_name = "nginxlog";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.nginxlog.port}"
            ];
          }
        ];
      }
    ];
    exporters.nginx.enable = true;
    exporters.nginxlog.enable = true;
  };
  ####
  # Permissions
  ####
  users.users.nginx.extraGroups = ["acme"];
  users.users.acme.extraGroups = ["nginx"];
  ####
  # Firewall
  ####
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/acme";
        mode = "744";
        user = "acme";
        group = "acme";
      }
      {
        directory = "/var/www";
        mode = "740";
        user = "nginx";
        group = "nginx";
      }
      {
        directory = "/var/lib/self-signed-nginx-cert";
        mode = "600";
        user = "nginx";
        group = "nginx";
      }
    ];
  };
}
