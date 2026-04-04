{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "koillection.home.a4blue.me";
in {
  ####
  # Main Config
  ####
  modules.koillection = {
    enable = true;
    environmentFiles = [
      (pkgs.writeText ".env" ''
        APP_DEBUG=0
        APP_ENV=prod
        HTTPS_ENABLED=0
        UPLOAD_MAX_FILESIZE=20M
        PHP_MEMORY_LIMIT=512M
        PHP_TZ=Europe/Berlin
        SYMFONY_TRUSTED_PROXIES=private_ranges
        SYMFONY_TRUSTED_HEADERS=forwarded,x-forwarded-for,x-forwarded-host,x-forwarded-proto,x-forwarded-port,x-forwarded-prefix
        CORS_ALLOW_ORIGIN='^https?://(${serviceDomain}|127\.0\.0\.1)(:[0-9]+)?$'
        JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem
        JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem
        DB_DRIVER=pdo_pgsql
        DB_NAME=koillection
        DB_HOST=host.docker.internal
        DB_PORT=${builtins.toString config.services.postgresql.settings.port}
        DB_USER=koillection
        DB_PASSWORD=koillection
        DB_VERSION=18
      '')
    ];
  };
  ####
  # Nginx
  ####
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.modules.koillection.port}";
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
        directory = config.modules.koillection.uploadDir;
        mode = "0777";
        user = "nobody";
        group = "nogroup";
      }
    ];
  };
}
