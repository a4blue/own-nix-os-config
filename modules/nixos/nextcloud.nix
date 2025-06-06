{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nginx.nix
    ./fail2ban.nix
    #./clamav.nix
  ];
  environment = {
    systemPackages = with pkgs; [
      exiftool
      nodejs_22
      ffmpeg_7
      perl
    ];
    etc = {
      "fail2ban/filter.d/nextcloud.conf".text = ''
            [Definition]
        _groupsre = (?:(?:,?\s*"\w+":(?:"[^"]+"|\w+))*)
        failregex = ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
                    ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
        datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
      '';
    };

    persistence."${config.modules.impermanenceExtra.defaultPath}" = {
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
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  sops.secrets.nextcloud-admin-pass = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  services = {
    nextcloud = {
      enable = true;
      https = true;
      hostName = "nextcloud.home.a4blue.me";
      configureRedis = true;
      caching.redis = true;
      database.createLocally = true;
      package = pkgs.nextcloud30;
      appstoreEnable = true;
      phpOptions."opcache.interned_strings_buffer" = "32";
      maxUploadSize = "4G";
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit
          app_api
          bookmarks
          calendar
          contacts
          cospend
          forms
          mail
          maps
          memories
          notes
          previewgenerator
          #recognize
          tasks
          #twofactor_totp
          whiteboard
          ;

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

    nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
      forceSSL = true;
      enableACME = true;
    };
    fail2ban = {
      jails = {
        nextcloud.settings = {
          backend = "auto";
          enabled = "true";
          port = "80,443";
          protocol = "tcp";
          filter = "nextcloud";
          maxretry = "3";
          bantime = "86400";
          findtime = "43200";
          logpath = "/var/lib/nextcloud/data/nextcloud.log";
        };
      };
    };
  };

  systemd.services.nextcloud-cron.path = [
    pkgs.exiftool
    pkgs.perl
    pkgs.ffmpeg_7
    pkgs.nodejs_22
  ];
}
