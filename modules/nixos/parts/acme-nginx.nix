{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "a4blue@hotmail.de";
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enable = true;
    virtualHosts = {
      "home.a4blue.me" = {
        forceSSL = true;
        enableACME = true;
        # All serverAliases will be added as extra domain names on the certificate.
        #serverAliases = [ "bar.example.com" ];
        locations."/" = {
          root = "/var/www";
        };
      };

      # We can also add a different vhost and reuse the same certificate
      # but we have to append extraDomainNames manually beforehand:
      # security.acme.certs."foo.example.com".extraDomainNames = [ "baz.example.com" ];
      #"baz.example.com" = {
      #  forceSSL = true;
      #  useACMEHost = "foo.example.com";
      #  locations."/" = {
      #    root = "/var/www";
      #  };
      #};
    };
  };
  users.users.nginx.extraGroups = ["acme"];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/acme"
    ];
  };
}
