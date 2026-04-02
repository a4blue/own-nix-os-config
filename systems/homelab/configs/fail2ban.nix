{config, ...}: {
  ####
  # Main Config
  ####
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.178.0/24"
    ];
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        # TODO maybe services.fail2ban.daemonSettings.Definition.dbfile is only needed ?
        directory = "/var/lib/fail2ban";
        mode = "0700";
        user = "root";
        group = "root";
      }
    ];
  };
}
