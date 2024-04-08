{config, ...}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.users.root.shell = "/bin/cryptsetup-askpass";
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      authorizedKeys = config.users.users.a4blue.openssh.authorizedKeys.keys;
      hostKeys = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
  };
}
