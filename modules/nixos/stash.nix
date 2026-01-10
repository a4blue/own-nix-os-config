{config, ...}: {
  services.stash = {
    enable = true;
    dataDir = "/var/lib/stash-new";
    username = "a4blue";
    passwordFile = "/nix/secret/stash_password";
    jwtSecretKeyFile = "/nix/secret/stash_jwt_token";
    sessionStoreKeyFile = "/nix/secret/stash_session_store_key";
    mutablePlugins = true;
    mutableScrapers = true;
    openFirewall = true;
    settings = {
      stash = [
        {
          path = "/LargeMedia/smb/Porn-New";
        }
      ];
      port = 9998;
      notifications_enabled = false;
      scrapers_path = "${config.services.stash.dataDir}/scrapers";
      plugins_path = "${config.services.stash.dataDir}/plugins";
      generated = "${config.services.stash.dataDir}/generated";
      database = "${config.services.stash.dataDir}/go.sqlite";
      cache = "${config.services.stash.dataDir}/cache";
      blobs_path = "${config.services.stash.dataDir}/blobs";
    };
    #settings.sequential_scanning = true;
  };
  users.users.stash.extraGroups = ["smbUser" "LargeMediaUsers"];
  systemd.services.stash.after = ["LargeMedia.mount"];

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "${config.services.stash.dataDir}";
        mode = "0740";
        user = "stash";
        group = "stash";
      }
    ];
  };
}
