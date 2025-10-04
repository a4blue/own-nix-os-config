{
  config,
  pkgs,
  ...
}: let
  servicePort = 8096;
  serviceDomain = "jellyfin.homelab.internal";
in {
  imports = [
    ./nginx.nix
    ./fail2ban.nix
  ];

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};
  environment.etc = {
    "fail2ban/jail.d/jellyfin.local".text = ''
      [jellyfin]
      backend = auto
      enabled = true
      port = 80,443
      protocol = tcp
      filter = jellyfin
      maxretry = 3
      bantime = 86400
      findtime = 43200
      logpath = /path_to_logs/jellyfin*.log
    '';
    "fail2ban/filter.d/jellyfin.conf".text = ''
      [Definition]
      failregex = ^.*Authentication request for .* has been denied \(IP: "<ADDR>"\)\.
    '';
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libva-vdpau-driver
      intel-compute-runtime
      vpl-gpu-rt
      intel-ocl
    ];
  };

  services.declarative-jellyfin = {
    enable = true;
    openFirewall = false;
    system = {
      serverName = "a4blue's нетflix";
      # Use Hardware Acceleration for trickplay image generation
      trickplayOptions = {
        enableHwAcceleration = true;
        enableHwEncoding = true;
      };
      UICulture = "en-US";
      pluginRepositories = [
        {
          content = {
            Name = "Jellyfin Stable";
            Url = "https://repo.jellyfin.org/files/plugin/manifest.json";
          };
          tag = "RepositoryInfo";
        }
      ];
    };
    libraries = {
      Movies = {
        enabled = true;
        contentType = "movies";
        pathInfos = ["/LargeMedia/smb/Movies Sorted"];
      };
      Shows = {
        enabled = true;
        contentType = "tvshows";
        pathInfos = ["/LargeMedia/smb/Series Sorted"];
      };
    };
    encoding = {
      allowAv1Encoding = false;
      allowHevcEncoding = true;
      enableDecodingColorDepth10Hevc = true;
      enableDecodingColorDepth10Vp9 = true;
      enableHardwareEncoding = true;
      enableSegmentDeletion = false;
      hardwareAccelerationType = "qsv";
      hardwareDecodingCodecs = [
        # enable the codecs your system supports
        "h264"
        "hevc"
        "vc1"
      ];
      qsvDevice = "/dev/dri/renderD128";
    };
    network = {
      publishedServerUriBySubnet = ["all=https://${serviceDomain}"];
    };
  };

  services.nginx.virtualHosts."${serviceDomain}" = {
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
        proxy_set_header X-Forwarded-Protocol $scheme;
        deny 192.168.178.1;
        allow 192.168.178.0/24;
        deny all;
        proxy_buffering off;
      '';
    };
    locations."/socket" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Protocol $scheme;
        deny 192.168.178.1;
        allow 192.168.178.0/24;
        deny all;
      '';
    };
  };

  users.users.jellyfin.extraGroups = ["render" "smbUser" "video"];

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/jellyfin";
        mode = "0740";
        user = "jellyfin";
        group = "jellyfin";
      }
    ];
  };
}
