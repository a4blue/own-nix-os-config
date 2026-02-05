{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  nc4nix = import "${inputs.nc4nix}/default.nix" {
    inherit (pkgs) lib fetchurl runCommand callPackage;
  };
in {
  imports = [
    ./nginx.nix
    ./fail2ban.nix
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

  sops.secrets."nextcloud/adminPass" = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  sops.secrets."nextcloud/whiteboardSecret" = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  sops.secrets."nextcloud/extraSecrets" = {
    owner = "nextcloud";
    group = "nextcloud";
  };
  services = {
    nextcloud-whiteboard-server = {
      enable = true;
      settings.NEXTCLOUD_URL = "https://nextcloud.home.a4blue.me";
      secrets = [config.sops.secrets."nextcloud/whiteboardSecret".path];
    };
    nextcloud = {
      enable = true;
      https = true;
      hostName = "nextcloud.home.a4blue.me";
      configureRedis = true;
      caching.redis = true;
      database.createLocally = true;
      package = pkgs.nextcloud31;
      appstoreEnable = false;
      phpOptions."opcache.interned_strings_buffer" = "32";
      maxUploadSize = "4G";
      autoUpdateApps.enable = false;
      extraAppsEnable = true;
      #phpExtraExtensions = all: [all.ldap];
      #secretFile = config.sops.secrets."nextcloud/extraSecrets".path;
      extraApps =
        {
          inherit
            (config.services.nextcloud.package.packages.apps)
            # List of apps we want to install and are already packaged in
            # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
            app_api
            bookmarks
            calendar
            contacts
            cospend
            deck
            end_to_end_encryption
            forms
            mail
            maps
            memories
            notes
            onlyoffice
            phonetrack
            previewgenerator
            richdocuments
            tasks
            user_oidc
            whiteboard
            ;
        }
        // {
          inherit
            (nc4nix.nextcloud-31)
            announcementcenter
            cfg_share_links
            duplicatefinder
            files_downloadactivity
            quota_warning
            recognize
            secrets
            transfer_quota_monitor
            ;
        };

      config = {
        dbtype = "pgsql";
        adminpassFile = config.sops.secrets."nextcloud/adminPass".path;
      };
      settings = {
        default_phone_region = "DE";
        maintenance_window_start = 3;
        log_type = "file";
        loglevel = 1;
        #mail_domain = "a4blue.me";
        mail_smtpmode = "smtp";
        mail_smtphost = "127.0.0.1";
        mail_smtpauth = false;
        mail_smtpport = 1025;
        mail_from_address = "homelab@a4blue.me";
        mail_smtpsecure = "";
        mail_smtpdebug = true;
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
          "OC\\Preview\\WebP"
        ];
      };
    };

    nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      extraConfig = ''
        add_header X-Content-Type-Options "nosniff";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag "noindex, nofollow";
        add_header X-Frame-Options "SAMEORIGIN";
        add_header Referrer-Policy "no-referrer";
      '';
    };
    nginx.virtualHosts."whiteboard-nextcloud.home.a4blue.me" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:3002";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header X-Forwarded-Protocol $scheme;
        '';
      };
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
