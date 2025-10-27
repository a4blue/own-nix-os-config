{config, ...}: {
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    # Hide these mounts from the sidebar of file managers
    hideMounts = true;

    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/tmp"
      "/var/tmp"
      "/var/cache"
      "/var/lib/systemd"
      "/var/lib/NetworkManager"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };
}
