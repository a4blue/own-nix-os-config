{
  config,
  pkgs,
  ...
}: {
  services.mysql = {
    enable = true;
    dataDir = "/var/lib/mysql";
    package = pkgs.mariadb;
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/mysql";
        mode = "0740";
        user = "mysql";
        group = "mysql";
      }
    ];
  };
}
