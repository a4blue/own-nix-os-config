{config, ...}: {
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
  #virtualisation.oci-containers.containers = {
  #  container-name = {
  #    image = "container-image";
  #    autoStart = true;
  #    ports = [ "127.0.0.1:1234:1234" ];
  #  };
  #};
  users.users.a4blue = {
    extraGroups = [
      "podman"
    ];
  };
}
