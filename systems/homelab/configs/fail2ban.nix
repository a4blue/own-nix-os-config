{config, ...}: {
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.178.0/24"
    ];
  };

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/fail2ban";
        mode = "0700";
        user = "root";
        group = "root";
      }
    ];
  };
}
