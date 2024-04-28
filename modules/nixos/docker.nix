{config, ...}: {
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.docker.daemon.settings = {
    data-root = "/var/lib/docker/data";
  };
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.oci-containers.backend = "docker";

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/docker";
        mode = "0700";
        user = "root";
        group = "root";
      }
    ];
  };
}
