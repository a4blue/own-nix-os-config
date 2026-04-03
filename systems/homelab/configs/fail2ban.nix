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
    files = [
      {
        file = config.services.fail2ban.daemonSettings.Definition.dbfile;
        mode = "0700";
        user = "root";
        group = "root";
      }
    ];
  };
}
