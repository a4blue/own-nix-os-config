{config, ...}: {
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    # Until https://github.com/koverstreet/bcachefs/issues/877 is fixed (Kernel 6.17 apparently ...)
    storageDriver = "overlay";

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
