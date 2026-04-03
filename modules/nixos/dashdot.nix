{
  config,
  lib,
  ...
}: let
  cfg = config.modules.dashdot;
in {
  options.modules.dashdot = {
    enable = lib.mkEnableOption "Dashdot";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "";
    };
    widgetList = lib.mkOption {
      description = "DASHDOT_WIDGET_LIST";
      type = lib.types.str;
      default = "cpu,storage,ram,network,gpu";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      dashdot = {
        image = "docker.io/mauricenino/dashdot:latest";
        autoStart = true;
        privileged = true;
        ports = ["127.0.0.1:${builtins.toString cfg.port}:3001"];
        volumes = ["/:/mnt/host:ro"];
        environment = {
          DASHDOT_WIDGET_LIST = cfg.widgetList;
          DASHDOT_ENABLE_CPU_TEMPS = "true";
        };
      };
    };
  };
}
