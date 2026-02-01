{
  config,
  pkgs,
  ...
}: {
  sops.secrets.dynv6TokenIPUpdate = {
    key = "dynv6Token";
  };

  systemd.services."dynv6-ip-update" = {
    enable = true;
    script = ''
      #!/bin/sh

      token=$(cat ${config.sops.secrets.dynv6TokenIPUpdate.path})
      rootZone=home.a4blue.me

      ${pkgs.curlFull}/bin/curl -k "https://ipv6.dynv6.com/api/update?token=''${token}&zone=''${rootZone}&ipv6prefix=auto"
      ${pkgs.curlFull}/bin/curl -k "https://ipv4.dynv6.com/api/update?token=''${token}&zone=''${rootZone}&ipv4=auto"
    '';
    restartIfChanged = true;
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers."dynv6-ip-update" = {
    enable = true;
    wantedBy = [
      "timers.target"
    ];
    after = [];
    timerConfig = {
      Unit = "dynv6-ip-update.service";
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
    };
  };
}
