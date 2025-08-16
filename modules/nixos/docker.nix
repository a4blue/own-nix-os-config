{config, ...}: {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };

    daemon.settings = {
      data-root = "/var/lib/docker/data";
    };
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
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
