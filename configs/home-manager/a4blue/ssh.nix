{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.ssh.enable {
  programs.ssh = {
    enableDefaultConfig = false;
    settings = {
      "homelab" = {
        HostName = "192.168.178.65";
        User = "a4blue";

        "UserKnownHostsFile" = "~/.ssh/homelab_known_hosts";
        "PKCS11Provider" = "/run/current-system/sw/lib/libtpm2_pkcs11.so";
      };
      "homelab-unlock" = {
        HostName = "192.168.178.65";
        User = "root";
        "UserKnownHostsFile" = "~/.ssh/homelab-unlock_known_hosts";
        "PKCS11Provider" = "/run/current-system/sw/lib/libtpm2_pkcs11.so";
      };
      "homelab-nk" = {
        HostName = "192.168.178.65";
        User = "a4blue";
        "UserKnownHostsFile" = "~/.ssh/homelab_known_hosts";
        "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
      };
      "homelab-unlock-nk" = {
        HostName = "192.168.178.65";
        User = "root";
        "UserKnownHostsFile" = "~/.ssh/homelab-unlock_known_hosts";
        "IdentityFile" = "~/.ssh/id_ed25519_sk_rk_9bff4ca58ab54a4c9973715e8c409e737b0df72132906345c58b885107431f4d";
      };
      "*" = {
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
