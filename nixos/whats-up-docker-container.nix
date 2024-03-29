{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    "whats-up-docker" = {
  # https://github.com/gethomepage/homepage/pkgs/container/homepage
      image = "ghcr.io/fmartinou/whats-up-docker:latest";
      autoStart = true;
      ports = [ "3001:3000" ];
      volumes = [ "/home/a4blue/services/whats-up-docker/store:/store" "/var/run/docker.sock:/var/run/docker.sock" ];
    };
  };
}
