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
    environmentFiles = lib.mkOption {
      type = with lib.types; listOf path;
      default = [];
      description = "Environment files for this container.";
      example = [
        /path/to/.env
        /path/to/.env.secret
      ];
    };
    uploadDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/koillection/uploads";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      koillection = {
        image = "docker.io/koillection/koillection:latest";
        autoStart = true;
        privileged = true;
        ports = ["127.0.0.1:${builtins.toString cfg.port}:80"];
        volumes = ["${cfg.uploadDir}:/uploads"];
        environmentFiles = cfg.environmentFiles;
      };
    };
    systemd.services.${config.virtualisation.oci-containers.containers.koillection.serviceName}.preStart = ''
      mkdir -p ${cfg.uploadDir}
    '';
    ####
    # Postgresql
    ####
    services.postgresql = {
      enable = true;
      ensureDatabases = ["koillection"];
      enableTCPIP = true;
    };
  };
}
