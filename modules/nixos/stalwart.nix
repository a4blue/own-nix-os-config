{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # currently rocksdb is included with stalwart-mail
    #rocksdb
  ];
  services.stalwart-mail = {
    enable = true;
    package = pkgs.stalwart-mail;
    openFirewall = false;
    settings = {
      server = {
        hostname = "localhost";
        tls.enable = false;
        listener = {
          "smtp-submission" = {
            bind = ["[::1]:587"];
            protocol = "smtp";
          };
          "imap" = {
            bind = ["[::1]:143"];
            protocol = "imap";
          };
        };
      };
      storage = {
        data = "rocksdb";
        blob = "rocksdb";
        fts = "rocksdb";
        lookup = "rocksdb";
        encryption.enable = false;
      };
      store."rocksdb" = {
        type = "rocksdb";
        path = "/var/lib/stalwart";
        purge.frequency = "0 3 *";
      };
      directory."memory" = {
        type = "memory";
        principals = [
          {
            class = "individual";
            name = "Hotmail Backup";
            description = "Backup for Hotmail";
            secret = "test";
            email = ["hotmail_backup@localhost"];
          }
        ];
      };
      queue = {
        schedule = {
          # its a backup server, so sending should expire fast
          expire = "1m";
        };
        outbound.next-hop = "'local'";
      };

      imap.auth.allow-plain-text = true;
      session.auth = {
        mechanisms = "[plain, login]";
      };
    };
  };

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/stalwart";
        mode = "0740";
        user = "stalwart-mail";
        group = "stalwart-mail";
      }
    ];
  };
}
