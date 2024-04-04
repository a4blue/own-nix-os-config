{
  config,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    homepage = {
      # https://github.com/gethomepage/homepage/pkgs/container/homepage
      image = "ghcr.io/gethomepage/homepage:latest";
      autoStart = true;
      ports = ["3000:3000"];
      volumes = ["/home/a4blue/services/homepage/config:/app/config" "/var/run/docker.sock:/var/run/docker.sock"];
    };
  };
}
