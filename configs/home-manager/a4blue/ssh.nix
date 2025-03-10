{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.ssh.enable) {
  programs.ssh = {
    addKeysToAgent = "confirm 1h";
    matchBlocks = {
      "homelab" = {
        hostname = "192.168.178.64";
        user = "a4blue";
        extraOptions = {
          "UserKnownHostsFile" = "homelab_known_hosts";
        };
      };
      "homelab-unlock" = {
        hostname = "192.168.178.64";
        user = "root";
        extraOptions = {
          "UserKnownHostsFile" = "homelab-unlock_known_hosts";
        };
      };
    };
  };
}
