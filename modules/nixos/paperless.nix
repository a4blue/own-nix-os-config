{config, ...}: let
  servicePort = 38001;
in {
  imports = [
    ./nginx.nix
    ./postgresql.nix
  ];
  services.paperless = {
    enable = true;
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
      PAPERLESS_URL = "https://homelab.armadillo-snake.ts.net";
      PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
      PAPERLESS_STATIC_URL = "/paperless/static/";
      PAPERLESS_ADMIN_USER = "a4blue";
      PAPERLESS_SECRET_KEY = "ZkURZGp)eBRT-yJie$@uHB7&h#X?(F3jN)CpUBeu%nyRRbn?U#nZpZ*18z6a#tdu";
      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_PORT = servicePort;
    };
  };

  services.postgresql = {
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

  services.nginx.virtualHosts."homelab.armadillo-snake.ts.net".locations."/paperless" = {
    recommendedProxySettings = true;
    proxyPass = "http://localhost:${builtins.toString servicePort}";
  };

  environment.persistence."/persistent" = {
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
