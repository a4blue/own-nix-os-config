{
  config,
  pkgs,
  ...
}: let
  servicePort = 38050;
  serviceDomain = "sabnzbd.home.a4blue.me";
in {
  imports = [
    ./nginx.nix
  ];
  users.users.sabnzbd.extraGroups = ["smbUser" "LargeMediaUsers"];
  systemd.services.sabnzbd = {
    after = ["LargeMedia.mount" "bcachefs-large-media-mount.service"];
    serviceConfig = {RestartSec = 5;};
  };
  sops.secrets.sabnzbd_secret_file = {
    owner = "sabnzbd";
    group = "sabnzbd";
  };
  services.sabnzbd = {
    enable = true;
    allowConfigWrite = true;
    secretFiles = ["${config.sops.secrets.sabnzbd_secret_file.path}"];
    settings = {
      misc = {
        port = servicePort;
        bandwidth_max = "8M";
        bandwidth_perc = 80;
        check_new_rel = 0;
        enable_https_verification = 1;
        download_dir = "/LargeMedia/smb/Sabnzbd/incomplete";
        complete_dir = "/LargeMedia/smb/Sabnzbd/complete";
        host_whitelist = "sabnzbd.home.a4blue.me";
      };
    };
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    extraConfig = ''
      client_max_body_size 20M;
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
      '';
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/sabnzbd";
        mode = "0740";
        user = "sabnzbd";
        group = "sabnzbd";
      }
    ];
  };
}
