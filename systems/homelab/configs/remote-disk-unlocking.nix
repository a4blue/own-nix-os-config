{config, ...}: {
  boot = {
    kernelParams = ["ip=dhcp"];
    initrd = {
      systemd.enable = true;
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys = config.users.users.a4blue.openssh.authorizedKeys.keys;
          hostKeys = [
            "/etc/ssh/ssh_host_ed25519_key"
          ];
          extraConfig = ''
            PrintMotd yes
            AllowTcpForwarding yes
            AllowAgentForwarding no
            AllowStreamLocalForwarding no
            AuthenticationMethods publickey
            PubkeyAuthOptions verify-required
          '';
        };
      };
      systemd.contents."/etc/motd".text = ''
        Use systemd-tty-ask-password-agent
      '';
    };
  };
}
