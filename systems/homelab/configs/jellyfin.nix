{
  config,
  pkgs,
  inputs,
  ...
}: let
  # Can only be set via UI for now
  servicePort = 8096;
  serviceDomain = "jellyfin.home.a4blue.me";
  dataDir = "/var/lib/jellyfin";
in {
  services = {
    ####
    # Main Config
    ####
    jellyfin = {
      enable = true;
      forceEncodingConfig = true;
      inherit dataDir;
      hardwareAcceleration = {
        enable = true;
        device = "/dev/dri/renderD128";
        type = "qsv";
      };
      transcoding = {
        h265Crf = 28;
        h264Crf = 23;
        enableToneMapping = true;
        enableSubtitleExtraction = true;
        enableIntelLowPowerEncoding = false;
        enableHardwareEncoding = true;
        deleteSegments = true;
        throttleTranscoding = false;
        threadCount = null;
        maxConcurrentStreams = null;
        hardwareEncodingCodecs = {
          hevc = true;
          av1 = true;
        };
        hardwareDecodingCodecs = {
          av1 = true;
          h264 = true;
          hevc = true;
          hevc10bit = true;
          hevcRExt10bit = true;
          hevcRExt12bit = true;
          mpeg2 = true;
          vc1 = false;
          vp8 = false;
          vp9 = true;
        };
      };
    };
    ####
    # Nginx
    ####
    nginx.virtualHosts."${serviceDomain}" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      http2 = true;
      http3 = true;
      quic = true;
      extraConfig = ''
        client_max_body_size 512M;
        add_header X-Content-Type-Options "nosniff";
      '';
      locations = {
        "/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
          extraConfig = ''
            proxy_set_header Range $http_range;
            proxy_set_header If-Range $http_if_range;
          '';
        };
        "/metrics" = {
          extraConfig = ''
            deny  all;
          '';
        };
      };
    };
    ####
    # Prometheus
    ####
    prometheus.scrapeConfigs = [
      {
        job_name = "jellyfin";
        static_configs = [
          {
            targets = [
              "localhost:${toString servicePort}"
            ];
          }
        ];
      }
    ];
  };
  environment = {
    ####
    # Intel Driver fix
    ####
    sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};
    ####
    # Fail2Ban Rules
    ####
    etc = {
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
        logpath = ${dataDir}/log/log*.log
      '';
      "fail2ban/filter.d/jellyfin.conf".text = ''
        [Definition]
        failregex = ^.*Authentication request for .* has been denied \(IP: "<ADDR>"\)\.
      '';
    };
    ####
    # Impermanence
    ####
    persistence."${config.modules.impermanenceExtra.defaultPath}" = {
      directories = [
        {
          directory = config.services.jellyfin.dataDir;
          mode = "0740";
          user = "jellyfin";
          group = "jellyfin";
        }
      ];
    };
  };
  ####
  # Intel Drivers
  ####
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
  ####
  # Systemd fixes
  ####
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  systemd.services.jellyfin = {
    after = ["LargeMedia.mount" "bcachefs-large-media-mount.service"];
    serviceConfig = {RestartSec = 5;};
  };
  ####
  # Driver Permissions
  ####
  users.users.jellyfin.extraGroups = ["render" "smbUser" "video" "LargeMediaUsers"];
  ####
  # Imports
  ####
  imports = [
    ./nginx.nix
    ./fail2ban.nix
    inputs.jellarr.nixosModules.default
  ];
}
