{config, ...}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      # better solution would be something like motd, in case i need the shell for something else
      # don't use if you use bcachefs
      #shell = "/bin/cryptsetup-askpass";
      authorizedKeys = config.users.users.a4blue.openssh.authorizedKeys.keys;
      hostKeys = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
  };
}
