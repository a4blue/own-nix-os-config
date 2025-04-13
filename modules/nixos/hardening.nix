{
  config,
  lib,
  ...
}: {
  #environment.defaultPackages = lib.mkForce [];
  #boot.kernelParams = ["quiet"];
  #boot.consoleLogLevel = 0;

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
  security = {
    sudo.execWheelOnly = true;
    auditd.enable = true;
    audit.enable = true;
    audit.rules = [
      "-a exit,always -F arch=b64 -S execve"
    ];
    sudo.wheelNeedsPassword = false;
  };
}
