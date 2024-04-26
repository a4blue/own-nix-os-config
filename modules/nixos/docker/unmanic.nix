{config, ...}: {
  imports = [
    ../docker.nix
  ];

  virtualisation.oci-containers.containers."unmanic-docker" = {
    image = "josh5/unmanic:latest";
    ports = ["8888:8888"];
    volumes = [
      "/var/lib/unmanic/config:/config"
      "/LargeMedia:/library"
      "/tmp/unmanic:/tmp/unmanic"
    ];
    extraOptions = ["--device=/dev/dri/renderD128"];
    user = "unmanic:unmanic";
  };

  users.users = {
    unmanic = {
      group = "unmanic";
      isNormalUser = true;
      home = "/var/lib/unmanic";
      extraGroups = ["smbUser" "render"];
    };
  };

  users.groups.unmanic = {};

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/unmanic";
        mode = "2744";
        user = "unmanic";
        group = "unmanic";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [8888];
}
