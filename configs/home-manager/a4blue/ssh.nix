{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.ssh.enable {
  programs.ssh = {
    enableDefaultConfig = false;
    matchBlocks = {
      "homelab" = {
        hostname = "192.168.178.64";
        user = "a4blue";
        extraOptions = {
          "UserKnownHostsFile" = "~/.ssh/homelab_known_hosts";
          "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
        };
      };
      "homelab-unlock" = {
        hostname = "192.168.178.64";
        user = "root";
        extraOptions = {
          "UserKnownHostsFile" = "~/.ssh/homelab-unlock_known_hosts";
          "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
        };
      };
      "homelab-new" = {
        hostname = "192.168.178.65";
        user = "a4blue";
        extraOptions = {
          "UserKnownHostsFile" = "~/.ssh/homelab_known_hosts";
          "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
        };
      };
      "homelab-new-unlock" = {
        hostname = "192.168.178.65";
        user = "root";
        extraOptions = {
          "UserKnownHostsFile" = "~/.ssh/homelab-unlock_known_hosts";
          "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
        };
      };
      "homelab-bak" = {
        hostname = "192.168.178.64";
        user = "a4blue";
        extraOptions = {
          "UserKnownHostsFile" = "~/.ssh/homelab_known_hosts";
          "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_HomeNet-Bak";
        };
      };
      "homelab-unlock-bak" = {
        hostname = "192.168.178.64";
        user = "root";
        extraOptions = {
          "UserKnownHostsFile" = "~/.ssh/homelab-unlock_known_hosts";
          "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_HomeNet-Bak";
        };
      };
      "*" = {
        extraOptions = {
          "ForwardAgent" = "no";
          "AddKeysToAgent" = "confirm 4h";
          "Compression" = "no";
          "ServerAliveInterval" = "0";
          "ServerAliveCountMax" = "3";
          "HashKnownHosts" = "no";
          "UserKnownHostsFile" = "~/.ssh/known_hosts";
          "ControlMaster" = "no";
          "ControlPath" = "~/.ssh/master-%r@%n:%p";
          "ControlPersist" = "no";
        };
      };
    };
  };
  home =
    if config.modules.impermanenceExtra.enabled
    then {
      persistence."${config.modules.impermanenceExtra.defaultPath}" = {
        directories = [
          ".ssh"
        ];
      };
    }
    else {};
}
