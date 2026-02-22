{
  config,
  pkgs,
  ...
}: {
  sops.secrets.spaceshipApiSecret = {};
  sops.secrets.spaceshipApiKey = {};

  systemd.services."dynamic-dns-ip-update" = {
    enable = true;
    script = ''
      #!/bin/sh

      secret=$(cat ${config.sops.secrets.spaceshipApiSecret.path})
      key=$(cat ${config.sops.secrets.spaceshipApiKey.path})
      file=/tmp/.dynamic-dns.addr6
      [ -e $file ] && old=`cat $file`

      ipv6=$(ip -6 addr list scope global enp86s0 | ${pkgs.gnugrep}/bin/grep -v " fd" | ${pkgs.gnused}/bin/sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | ${pkgs.coreutils}/bin/head -n 1)

      if [ "$old" = "$ipv6" ]; then
        echo "IPv6 address unchanged"
        exit
      fi

      ipv4="$(${pkgs.curlFull}/bin/curl -s -X GET https://api.ipify.org)"

      ${pkgs.curlFull}/bin/curl -v -X PUT https://spaceship.dev/api/v1/dns/records/a4blue.me \
        -H "X-API-Key: ''${key}"
        -H "X-API-Secret: ''${secret}"
        -H "Accept: application/json"
        -H "Content-Type: application/json"
        -d "{"force":true,"items":[{"type":"A","address":"''${ipv4}","name":"*.home","ttl":60},{"type":"AAAA","address":"''${ipv6}","name":"*.home","ttl":60}]}"

      echo $ipv6 > $file
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
