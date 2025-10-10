{config, ...}: {
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        security = "user";
        "hosts allow" = "192.168.178.0/24 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "LargeMedia" = {
        path = "/LargeMedia/smb";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "2777";
        "directory mask" = "2777";
        "force user" = "a4blue";
        "force group" = "smbUser";
      };
    };
  };
  users.groups.smbUser = {
    members = ["a4blue"];
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    publish.enable = true;
    publish.userServices = true;
    nssmdns4 = true;
    enable = true;
    openFirewall = true;
  };
  networking.firewall.allowPing = true;

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/samba";
        mode = "0740";
        user = "root";
        group = "root";
      }
    ];
  };
}
