{
  config,
  lib,
  ...
}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd.systemd.enable = true;
  #boot.initrd.systemd.users.root.shell = "systemd-tty-ask-password-agent --query";
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      authorizedKeys = config.users.users.a4blue.openssh.authorizedKeys.keys;
      hostKeys = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      extraConfig = ''PrintMotd yes'';
      #shell = "";
    };
  };
  boot.initrd.systemd.contents."/etc/motd".text = ''
    Use systemd-tty-ask-password-agent
  '';
}
