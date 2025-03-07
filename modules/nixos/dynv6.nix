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
      zone=home.a4blue.me

      curl -k "https://ipv6.dynv6.com/api/update?token=''${token}&zone=''${zone}&ipv6prefix=auto"
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
