{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    curlFull
  ];
  sops.secrets.dynv6_token = {};

  systemd.services."dynv6-ip-update" = {
    enable = true;
    script = ''
      #!/bin/sh

      token=$(cat ${config.sops.secrets.dynv6_token.path})
      rootZone=home.a4blue.me

      curl -k "https://ipv6.dynv6.com/api/update?token=''${token}&zone=nextcloud.''${rootZone}&ipv6prefix=auto"
      curl -k "https://ipv6.dynv6.com/api/update?token=''${token}&zone=homelab.''${rootZone}&ipv6prefix=auto"

      curl -k "https://ipv4.dynv6.com/api/update?token=''${token}&zone=nextcloud.''${rootZone}&ipv4=auto"
      curl -k "https://ipv4.dynv6.com/api/update?token=''${token}&zone=homelab.''${rootZone}&ipv4=auto"
    
    '';
    restartIfChanged = true;
    serviceConfig = {
      Type = "oneshot";
    };
    path = with pkgs; [
      curlFull
    ];
  };

  systemd.timers."dynv6-ip-update" = {
    enable = true;
    wantedBy = [
      "timers.target"
    ];
    after = [];
    timerConfig = {
      Unit = "dynv6-ip-update.service";
      OnBootSec = "10m";
      OnUnitActiveSec = "10m";
    };
  };
}
