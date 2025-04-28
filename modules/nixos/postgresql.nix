{
  config,
  pkgs,
  ...
}: {
  services.postgresql = {
    enable = true;
    #identMap = ''
    ## ArbitraryMapName systemUser DBUser
    #   superuser_map      root      postgres
    #   superuser_map      postgres  postgres
    #   # Let other names login as themselves
    #   superuser_map      /^(.*)$   \1
    #'';
    #initialScript = pkgs.writeText "init-sql-script" ''
    #  ALTER USER paperless PASSWORD 'paperless';
    #'';
  };

  # temp debug
  #services.pgadmin = {
  #  enable = true;
  #  openFirewall = true;
  #  initialPasswordFile = "/nix/secret/weak_password";
  #  initialEmail = "test@test.com";
  #};

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/postgresql";
        mode = "0740";
        user = "postgres";
        group = "postgres";
      }
    ];
  };
}
