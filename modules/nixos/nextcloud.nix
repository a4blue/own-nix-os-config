{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nginx.nix
  ];
  environment.systemPackages = with pkgs; [
    exiftool
    nodejs_21
    ffmpeg_7
    perl
  ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  sops.secrets.nextcloud-admin-pass = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    https = true;
    hostName = "nextcloud.home.a4blue.me";
    configureRedis = true;
    caching.redis = true;
    database.createLocally = true;
    package = pkgs.nextcloud28;
    appstoreEnable = true;
    phpOptions."opcache.interned_strings_buffer" = "32";
    maxUploadSize = "4G";
    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      # List of apps we want to install and are already packaged in
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
      inherit bookmarks calendar contacts mail notes tasks previewgenerator maps memories;

      #recognize = pkgs.fetchNextcloudApp {
      #  url = "https://github.com/nextcloud/recognize/releases/download/v6.1.1/recognize-6.1.1.tar.gz";
      #  sha256 = "sha256-ziUc4J2y1lW1BwygwOKedOWbeAnPpBDwT9wh35R0MYk=";
      #  license = "agpl3Plus";
      #  appVersion = "6.1.1";
      #  description = "👁 👂 Smart media tagging for Nextcloud: recognizes faces, objects, landscapes, music genres";
      #  homepage = "https://apps.nextcloud.com/apps/recognize";
      #  appName = "recognize";
      #};
    };

    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
    };
    settings = {
      default_phone_region = "DE";
      maintenance_window_start = 3;
      log_type = "file";
      loglevel = 1;
    };
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
    forceSSL = true;
    enableACME = true;
  };

  systemd.services.nextcloud-cron.path = [pkgs.exiftool pkgs.perl pkgs.ffmpeg_7 pkgs.nodejs_21];

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/nextcloud";
        mode = "0740";
        user = "nextcloud";
        group = "nextcloud";
      }
      {
        directory = "/var/lib/redis-nextcloud";
        mode = "0740";
        user = "redis-nextcloud";
        group = "redis-nextcloud";
      }
    ];
  };
}
