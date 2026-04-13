{config, ...}: {
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    # Hide these mounts from the sidebar of file managers
    hideMounts = true;

    directories = [
      "/tmp"
      "/var/log"
      "/var/tmp"
      "/var/cache"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/NetworkManager"
      "/var/lib"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };
  #systemd.tmpfiles.rules = [
  #  "d ${config.modules.impermanenceExtra.defaultPath}/var/lib/private 0700 root root -"
  #];
}
