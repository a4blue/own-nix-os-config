{config, ...}: {
  ####
  # Main Config
  ####
  virtualisation = {
    containers.enable = true;
    containers.containersConf.settings = {network.dns_bind_port = 5300;};
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      defaultNetwork.settings.dns_bind_port = 5300;
    };
  };
  virtualisation.oci-containers.backend = "podman";
  ####
  # Permissions
  ####
  users.users.a4blue = {
    extraGroups = [
      "podman"
    ];
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/containers";
        mode = "0777";
        user = "root";
        group = "root";
      }
    ];
  };
}
