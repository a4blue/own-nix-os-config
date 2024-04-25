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
    user = "root:root";
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/unmanic";
        mode = "2744";
        user = "root";
        group = "root";
      }
    ];
  };

  #users = optionalAttrs (cfg.user == defaultUser) {
  #    users.${defaultUser} = {
  #      group = defaultUser;
  #      uid = config.ids.uids.paperless;
  #      home = cfg.dataDir;
  #    };
  #    groups.${defaultUser} = {
  #      gid = config.ids.gids.paperless;
  #    };

  #users.users."unmanic" = {};
  networking.firewall.allowedTCPPorts = [8888];
}
