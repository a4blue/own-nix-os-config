{config, ...}: {
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "a4blue@hotmail.de";
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enable = true;
    tailscaleAuth.enable = true;
    virtualHosts = {
      "home.a4blue.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
        };
      };
      "homelab.armadillo-snake.ts.net" = {
        forceSSL = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://localhost:3000";
        };
        sslCertificate = "/var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.crt";
        sslCertificateKey = "/var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.key";
      };
      "_" = {
        globalRedirect = "home.a4blue.de";
        default = true;
      };
    };
    tailscaleAuth.virtualHosts = [];
  };
  users.users.nginx.extraGroups = ["acme"];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/acme"
    ];
  };
}
