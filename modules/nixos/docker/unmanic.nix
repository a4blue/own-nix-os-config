{config, ...}: let
  servicePort = 8888;
  # Not used yet
  serviceDomain = "unmanic.homelab.internal";
in {
  imports = [
    ../docker.nix
  ];

  virtualisation.oci-containers.containers."unmanic-docker" = {
    image = "josh5/unmanic:latest";
    ports = ["${builtins.toString servicePort}:8888"];
    volumes = [
      "/var/lib/unmanic/config:/config"
      "/LargeMedia:/library"
      "/tmp/unmanic:/tmp/unmanic"
    ];
    extraOptions = ["--device=/dev/dri/renderD128"];
    user = "unmanic:unmanic";
    autoStart = false;
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

  networking.firewall.allowedTCPPorts = [servicePort];
}
