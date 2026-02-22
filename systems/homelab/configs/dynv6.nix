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
      file=/tmp/.dynv6.addr6
      [ -e $file ] && old=`cat $file`

      address=$(ip -6 addr list scope global enp86s0 | ${pkgs.gnugrep}/bin/grep -v " fd" | ${pkgs.gnused}/bin/sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | ${pkgs.coreutils}/bin/head -n 1)

      if [ "$old" = "$address" ]; then
        echo "IPv6 address unchanged"
        exit
      fi

      ipv4="$(${pkgs.curlFull}/bin/curl -s -X GET https://api.ipify.org)"

      ${pkgs.curlFull}/bin/curl -k "https://ipv6.dynv6.com/api/update?token=''${token}&zone=''${rootZone}&ipv6prefix=auto"
      ${pkgs.curlFull}/bin/curl -k "https://ipv4.dynv6.com/api/update?token=''${token}&zone=''${rootZone}&ipv4=auto"

      ID="$(${pkgs.curlFull}/bin/curl -s -X GET https://dynv6.com/api/v2/zones/5211604/records \
      -H "Authorization: Bearer ''${token}" \
      -H "Accept: application/json" | ${pkgs.jq}/bin/jq --args "map(select(.type == \"AAAA\" and .name == \"*\")).[0].id"
      )"
      if [ $ID == "null" ]; then
        ${pkgs.curlFull}/bin/curl -v -X POST https://dynv6.com/api/v2/zones/5211604/records \
          -H "Authorization: Bearer ''${token}" \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          -d "{\"name\":\"*\",\"data\":\"''${address}\",\"type\":\"AAAA\"}"
      else
        ${pkgs.curlFull}/bin/curl -v -X PATCH https://dynv6.com/api/v2/zones/5211604/records/''${ID} \
          -H "Authorization: Bearer ''${token}" \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          -d "{\"name\":\"*\",\"data\":\"''${address}\",\"type\":\"AAAA\"}"
      fi

      ID="$(${pkgs.curlFull}/bin/curl -s -X GET https://dynv6.com/api/v2/zones/5211604/records \
      -H "Authorization: Bearer ''${token}" \
      -H "Accept: application/json" | ${pkgs.jq}/bin/jq --args "map(select(.type == \"A\" and .name == \"*\")).[0].id"
      )"
      if [ $ID == "null" ]; then
        ${pkgs.curlFull}/bin/curl -v -X POST https://dynv6.com/api/v2/zones/5211604/records \
          -H "Authorization: Bearer ''${token}" \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          -d "{\"name\":\"*\",\"data\":\"''${ipv4}\",\"type\":\"A\"}"
      else
        ${pkgs.curlFull}/bin/curl -v -X PATCH https://dynv6.com/api/v2/zones/5211604/records/''${ID} \
          -H "Authorization: Bearer ''${token}" \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          -d "{\"name\":\"*\",\"data\":\"''${ipv4}\",\"type\":\"A\"}"
      fi

      echo $address > $file
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
