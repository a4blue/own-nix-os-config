{
  config,
  ...
}: let
  #servicePort = 38003;
  serviceDomain = "firefly.homelab.internal";
in {
  imports = [
    ./nginx.nix
    ./postgresql.nix
  ];

  services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = serviceDomain;
    settings = {
      DB_CONNECTION = "pgsql";
      DB_HOST = "/run/postgresql";
      DB_PORT = 5432;
      DB_DATABASE = "firefly";
      DB_USERNAME = "firefly";
      # Use echo "base64:$(head -c 32 /dev/urandom | base64)" > /nix/secret/firefly-iii-key
      APP_KEY_FILE = "/nix/secret/firefly-iii-key";
    };
  };

  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
    sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
    extraConfig = ''
      ssl_stapling off;
    '';
  };

  services.postgresql = {
    ensureDatabases = ["firefly-iii"];
    ensureUsers = [
      {
        name = "firefly-iii";
        ensureDBOwnership = true;
      }
    ];
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/firefly-iii";
        mode = "0740";
        user = "firefly-iii";
        group = "firefly-iii";
      }
    ];
  };
}
