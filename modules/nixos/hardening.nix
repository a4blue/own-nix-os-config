{config, ...}: {
  boot.kernelParams = ["quiet"];
  boot.consoleLogLevel = 0;
  security.sudo.wheelNeedsPassword = false;
  services = {
    openssh = {
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      openFirewall = true;
      allowSFTP = false;
      extraConfig = ''
        AllowTcpForwarding yes
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
  };

  networking = {
    firewall.enable = true;
  };

  nix.settings.allowed-users = ["@wheel"];
  security.sudo.execWheelOnly = true;
}
