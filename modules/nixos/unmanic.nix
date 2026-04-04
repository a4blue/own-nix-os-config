{
  config,
  lib,
  ...
}: let
  cfg = config.modules.unmanic;
in {
  options.modules.unmanic = {
    enable = lib.mkEnableOption "Unamnic";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      unmanic = {
        #podman.user = "a4blue";
        image = "docker.io/josh5/unmanic:latest";
        autoStart = true;
        ports = ["127.0.0.1:${builtins.toString cfg.port}:8888"];
        volumes = [
          "/var/lib/unmanic:/config"
          "/LargeMedia/smb:/library"
          "/var/cache/unmanic:/tmp/unmanic"
          "/dev/dri:/dev/dri"
        ];
        #environment = {
        #  PUID = "${builtins.toString config.users.users.a4blue.uid}";
        #  PGID = "${builtins.toString config.users.groups.LargeMediaUsers.gid}";
        #};
        # TODO find a better way to give permission to render and video group (maybe the user podman needs it ?)
        privileged = true;

        #extraOptions = ["--group-add" "keep-groups" "--userns" "keep-id"];
        #user = "a4blue:LargeMediaUsers";
      };
    };
  };
}
