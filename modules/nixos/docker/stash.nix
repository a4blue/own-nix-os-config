{config, ...}: {
  imports = [
    ../docker.nix
  ];

  virtualisation.oci-containers.containers."stash-container" = {
    image = "stashapp/stash:latest";
    ports = ["9999:9999"];
    volumes = [];
    extraOptions = ["--device=/dev/dri/renderD128"];
    user = "a4blue:users";
    autoStart = false;
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/stash";
        mode = "2740";
        user = "a4blue";
        group = "users";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [9999];
}
