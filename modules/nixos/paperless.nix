{config, ...}: let
  servicePort = 38001;
  serviceDomain = "paperless.homelab.internal";
in {
  imports = [
    ./nginx.nix
    ./postgresql.nix
  ];
  services = {
    paperless = {
      enable = true;
      port = servicePort;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
        PAPERLESS_URL = "https://${serviceDomain}";
        PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
        PAPERLESS_STATIC_URL = "/paperless/static/";
        PAPERLESS_ADMIN_USER = "a4blue";
        PAPERLESS_SECRET_KEY = "ZkURZGp)eBRT-yJie$@uHB7&h#X?(F3jN)CpUBeu%nyRRbn?U#nZpZ*18z6a#tdu";
        PAPERLESS_DBENGINE = "postgresql";
        PAPERLESS_DBHOST = "/run/postgresql";
      };
    };

    postgresql = {
      ensureDatabases = [
        "paperless"
      ];
      ensureUsers = [
        {
          name = "paperless";
          ensureDBOwnership = true;
        }
      ];
    };

    nginx.virtualHosts."${serviceDomain}" = {
      forceSSL = true;
      sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
      sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
      extraConfig = ''
        ssl_stapling off;
      '';
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://localhost:${builtins.toString servicePort}";
        extraConfig = ''
          deny 192.168.178.1;
          allow 192.168.178.0/24;
          deny all;
        '';
      };
    };
  };

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/paperless";
        mode = "0740";
        user = "paperless";
        group = "paperless";
      }
      {
        directory = "/var/lib/redis-paperless";
        mode = "0740";
        user = "redis-paperless";
        group = "redis-paperless";
      }
    ];
  };
}
