{
  config,
  lib,
  ...
}: {
  #environment.defaultPackages = lib.mkForce [];
  #boot.kernelParams = ["quiet"];
  #boot.consoleLogLevel = 0;
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
        PubkeyAuthOptions verify-required
      '';
    };
  };

  networking = {
    firewall.enable = true;
  };

  nix.settings.allowed-users = ["@wheel"];
  security.sudo.execWheelOnly = true;
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [
    "-a exit,always -F arch=b64 -S execve"
  ];
}
