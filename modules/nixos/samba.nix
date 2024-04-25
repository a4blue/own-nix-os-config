{config, ...}: {
  environment.persistence."/SDMedia" = {
    directories = [
      {
        directory = "/export/SDMedia";
        user = "nobody";
        group = "nogroup";
      }
    ];
  };
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.178.0/24 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      private = {
        path = "/export/SDMedia";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "2777";
        "directory mask" = "2777";
        "force user" = "a4blue";
        "force group" = "users";
      };
      "LargeMedia" = {
        path = "/LargeMedia/smb";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "2777";
        "directory mask" = "2777";
        "force user" = "a4blue";
        "force group" = "users";
      };
    };
  };
  networking.firewall.allowPing = true;
}
