{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    curlFull
    iproute2
    gnugrep
    gnused
    coreutils-full
  ];
  sops.secrets.dynv6_token = {};

  systemd.services."dynv6-ip-update" = {
    enable = true;
    script = ''
      #!/bin/sh

      newIpV6=$(ip -6 addr show scope global | grep inet6 | sed -e 's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | head -n 1)
      oldIpV6='No data in cachefile'
      newIpV4=$(curl https://api.ipify.org)
      oldIpv4='No data in cachefile'

      # Change these parameters as you want to

      logfile=~/dynv6.log
      cachefilev6=~/.dynv6cachev6
      cachefilev4=~/.dynv6cachev4
      token=$(cat ${config.sops.secrets.dynv6_token.path})
      zone=home.a4blue.me

      if [[ -f $cachefilev6 ]]; then
          oldIpV6=$(cat $cachefilev6)
      fi

      if [[ $newIpV6 != $oldIpV6 ]]; then
          echo "$(date): Updating the DNS. Output can be found in ''${logfile}"
          echo "$(date): $(curl -k "https://dynv6.com/api/update?token=''${token}&zone=''${zone}&ipv6=''${newIpV6}")" | tee -a $logfile
          echo $newIpV6 > $cachefilev6
      else
          echo "$(date): IPv6 did not Change. Skipping the update" | tee -a $logfile
      fi

      if [[ $newIpV4 != $oldIpV4 ]]; then
          echo "$(date): Updating the DNS. Output can be found in ''${logfile}"
          echo "$(date): $(curl -k "https://dynv6.com/api/update?token=''${token}&zone=''${zone}&ipv4=''${newIpV4}")" | tee -a $logfile
          echo $newIpV6 > $cachefilev4
      else
          echo "$(date): IPv4 did not Change. Skipping the update" | tee -a $logfile
      fi
    '';
    restartIfChanged = true;
    serviceConfig = {
      Type = "oneshot";
    };
    path = with pkgs; [
      curlFull
      iproute2
      gnugrep
      gnused
      coreutils-full
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
