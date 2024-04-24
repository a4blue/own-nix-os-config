{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    curlFull
  ];
  sops.secrets.dynu_ip_update_password = {};

  systemd.services."dynu-ip-update" = {
    enable = true;
    script = ''
      IPPASSWORD=$(cat ${config.sops.secrets.dynu_ip_update_password.path})
      curl "http://api-ipv6.dynu.com/nic/update?username=a4blue&password=$IPPASSWORD"
      curl "http://api-ipv4.dynu.com/nic/update?username=a4blue&password=$IPPASSWORD"
      unset IPPASSWORD
    '';
    restartIfChanged = true;
    serviceConfig = {
      Type = "oneshot";
    };

    systemd.timers."dynu-ip-update" = {
      enable = true;
      wantedBy = [
        "timers.target"
      ];
      after = ["network-online.target"];
      timerConfig = {
        Unit = "dynu-ip-update.service";
        OnBootSec = "10m";
        OnUnitActiveSec = "10m";
      };
    };
  };
}
