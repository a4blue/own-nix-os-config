{config, ...}: {
  imports = [
    ./tailscale-nginx-certs.nix
  ];
  sops.secrets.dynu_api_key = {};
  security.acme = {
    acceptTerms = true;
    defaults.email = "a4blue@hotmail.de";
    #certs."home-test.a4blue.me" = {
    #  domain = "home-test.a4blue.me";
    #  extraDomainNames = ["*.home-test.a4blue.me"];
    #  dnsProvider = "dynu";
    #  dnsPropagationCheck = true;
    #  credentialFiles = {
    #    "DYNU_API_KEY_FILE" = config.sops.secrets.dynu_api_key.path;
    #  };
    #};
  };
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enable = true;
    tailscaleAuth.enable = true;
    virtualHosts = {
      # Public DynDNS
      "home.a4blue.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
        };
      };
      "home-test.a4blue.me" = {
        #forceSSL = true;
        #useACMEHost = "home-test.a4blue.me";
        locations."/" = {
          root = "/var/www";
        };
      };
      # Tailscale
      "homelab.armadillo-snake.ts.net" = {
        forceSSL = true;
        sslCertificate = "/var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.crt";
        sslCertificateKey = "/var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.key";
      };
      # Default match
      "_" = {
        globalRedirect = "home.a4blue.me";
        default = true;
      };
    };
    tailscaleAuth.virtualHosts = ["homelab.armadillo-snake.ts.net"];
  };
  users.users.nginx.extraGroups = ["acme"];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/acme";
        mode = "740";
        user = "acme";
        group = "acme";
      }
      {
        directory = "/var/www";
        mode = "740";
        user = "nginx";
        group = "nginx";
      }
    ];
  };
}
