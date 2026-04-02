{
  config,
  lib,
  ...
}: let
  cfg = config.modules.koillection;
in {
  options.modules.koillection = {
    enable = lib.mkEnableOption "Koillection";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      koillection = {
        image = "docker.io/koillection/koillection:latest";
        autoStart = true;
        privileged = true;
        ports = ["127.0.0.1:${builtins.toString cfg.port}:80"];
        volumes = ["/:/mnt/host:ro"];
        environment = {
        };
      };
    };
  };
}
