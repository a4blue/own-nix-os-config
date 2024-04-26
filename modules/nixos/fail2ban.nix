{config, ...}: {
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.178.0/24"
    ];
  };
}
