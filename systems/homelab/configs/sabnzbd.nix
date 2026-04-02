{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "sabnzbd.home.a4blue.me";
  stateDir = "sabnzbd";
in {
  services = {
    ####
    # Main Config
    ####
    sabnzbd = {
      enable = true;
      inherit stateDir;
      allowConfigWrite = true;
      secretFiles = ["${config.sops.secrets.sabnzbd_secret_file.path}"];
      settings = {
        misc = {
          bandwidth_max = "8M";
          bandwidth_perc = 60;
          check_new_rel = 0;
          enable_https_verification = 1;
          download_dir = "/LargeMedia/smb/Sabnzbd/incomplete";
          complete_dir = "/LargeMedia/smb/Sabnzbd/complete";
          host_whitelist = "sabnzbd.home.a4blue.me";
          cache_limit = "512M";
          notified_new_skin = 1;
        };
      };
    };
    ####
    # Prometheus
    ####
    prometheus.exporters.sabnzbd = {
      enable = false;
      servers = [
        {
          baseUrl = "";
          apiKeyFile = "";
        }
      ];
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
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.sabnzbd.settings.misc.port}";
        extraConfig = ''
          proxy_set_header X-Forwarded-Protocol $scheme;
          proxy_buffering off;
        '';
      };
    };
  };
  ####
  # Permissions
  ####
  users.users.sabnzbd.extraGroups = ["smbUser" "LargeMediaUsers"];
  ####
  # Systemd Service
  ####
  systemd.services.sabnzbd = {
    after = ["LargeMedia.mount" "bcachefs-large-media-mount.service"];
    serviceConfig = {RestartSec = 5;};
  };
  ####
  # Secrets
  ####
  sops.secrets.sabnzbd_secret_file = {
    owner = "sabnzbd";
    group = "sabnzbd";
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/${stateDir}";
        mode = "0740";
        user = "sabnzbd";
        group = "sabnzbd";
      }
    ];
  };
}
