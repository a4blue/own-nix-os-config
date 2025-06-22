{
  config,
  pkgs,
  lib,
  ...
}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };

  environment.systemPackages = [
    (let
      newPostgres =
        pkgs.postgresql_17.withPackages (pp: [
        ]);
      cfg = config.services.postgresql;
    in
      pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -eux
        # XXX it's perhaps advisable to stop all services that depend on postgresql
        systemctl stop postgresql

        export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
        export NEWBIN="${newPostgres}/bin"

        export OLDDATA="${cfg.dataDir}"
        export OLDBIN="${cfg.finalPackage}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}

        sudo -u postgres "$NEWBIN/pg_upgrade" \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
          "$@"
      '')
  ];

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
