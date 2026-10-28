{
  config,
  pkgs,
  ...
}: {
  ####
  # Main Config
  ####
  services.nginx = {
    additionalModules = [pkgs.nginxModules.develkit];
    lua.enable = true;
    # Own TLS 1.3 only Config below
    recommendedTlsSettings = false;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    recommendedBrotliSettings = true;
    statusPage = true;
    enable = true;
    commonHttpConfig = ''
      # https://configurator.tlsref.org/#server=nginx&version=1.31.3&config=modern&openssl=3.5.9&hsts&guideline=6.0
      # modern configuration
      ssl_protocols TLSv1.3;
      ssl_ecdh_curve X25519MLKEM768:X25519:prime256v1:secp384r1;
      ssl_prefer_server_ciphers off;
    '';
    virtualHosts = {
      # Public DynDNS
      "homelab.home.a4blue.me" = {
        forceSSL = true;
        http2 = true;
        http3 = true;
        quic = true;
        useACMEHost = "home.a4blue.me";
        locations."/" = {
          root = "/var/www";
        };
      };
      # Default match
      "_" = {
        globalRedirect = "homelab.home.a4blue.me";
        default = true;
        http2 = true;
        http3 = true;
        quic = true;
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
