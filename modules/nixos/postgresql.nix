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

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/postgresql"
    ];
  };
}
