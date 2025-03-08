{config, ...}: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "a4blue@hotmail.de";
      dnsResolver = "1.1.1.1:53";
    };
  };
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enable = true;
    virtualHosts = {
      # Public DynDNS
      "home.a4blue.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
        };
      };
      # Default match
      "_" = {
        globalRedirect = "home.a4blue.me";
        default = true;
      };
    };
  };
  users.users.nginx.extraGroups = ["acme"];
  users.users.acme.extraGroups = ["nginx"];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.persistence."/persistent" = {
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
