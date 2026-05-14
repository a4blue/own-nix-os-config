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
  ####
  # Secrets
  ####
  sops.secrets.jellarrApiKey = {
    owner = "jellyfin";
    group = "jellyfin";
  };
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
    # Jellarr Config for "declarative" Jellyfin
    ####
    jellarr = {
      # TODO fix after checksum issue is resolved
      enable = false;
      user = "jellyfin";
      group = "jellyfin";
      environmentFile = config.sops.secrets.jellarrApiKey.path;
      config = {
        version = 1;
        base_url = "https://${serviceDomain}";
        system = {
          enableMetrics = true;
          trickplayOptions = {
            enableHwAcceleration = true;
            enableHwEncoding = true;
          };
          pluginRepositories = [
            {
              name = "Jellyfin Stable";
              url = "https://repo.jellyfin.org/files/plugin/manifest.json";
              enabled = true;
            }
            {
              name = "Merge Plugin";
              url = "https://raw.githubusercontent.com/danieladov/JellyfinPluginManifest/master/manifest.json";
              enabled = true;
            }
            {
              name = "SSO Plugin";
              url = "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json";
              enabled = true;
            }
            {
              name = "Intro Skipper Plugin";
              url = "https://intro-skipper.org/manifest.json";
              enabled = true;
            }
            {
              name = "File Transformation & Plugin Pages Plugins";
              url = "https://www.iamparadox.dev/jellyfin/plugins/manifest.json";
              enabled = true;
            }
            {
              name = "Editors Choice Plugin";
              url = "https://github.com/lachlandcp/jellyfin-editors-choice-plugin/raw/main/manifest.json";
              enabled = true;
            }
            {
              name = "Local Recommendation Plugin";
              url = "https://raw.githubusercontent.com/rdpharr/jellyfin-plugin-localrecs/main/manifest.json";
              enabled = true;
            }
            {
              name = "Jellyfin SmartLists Plugin";
              url = "https://raw.githubusercontent.com/jyourstone/jellyfin-plugin-manifest/main/manifest.json";
              enabled = true;
            }
            {
              name = "Bazarr Plugin";
              url = "https://raw.githubusercontent.com/enoch85/bazarr-jellyfin/main/manifest.json";
              enabled = true;
            }
            {
              name = "Jellyfin Language Tags Plugin";
              url = "https://raw.githubusercontent.com/TheXaman/jellyfin-plugin-languageTags/main/manifest.json";
              enabled = true;
            }
          ];
        };
        branding = {
          customCss = ''
            a.raised.emby-button {
              padding: 0.9em 1em;
              color: inherit !important;
            }

            .disclaimerContainer {
              display: block;
            }
          '';
          loginDisclaimer = ''
            <form action="https://jellyfin.home.a4blue.me/sso/OID/start/auth.home.a4blue.me">
              <button class="raised block emby-button button-submit">
                Sign in with SSO
              </button>
            </form>
          '';
        };
      };
    };
    ####
    # Nginx
    ####
    nginx.virtualHosts."${serviceDomain}" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      extraConfig = ''
        client_max_body_size 512M;
        add_header X-Content-Type-Options "nosniff";
      '';
      locations = {
        "/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
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
