{config, ...}: {
  services.traefik = {
    enable = true;
    staticConfigFile = ./traefik/staticConfig.yaml;
    dynamicConfigFile = ./traefik/dynamicConfig.yaml;
  };

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/traefik"
    ];
  };
}
