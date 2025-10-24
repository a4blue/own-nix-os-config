{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.services.fwupd.enable {
  environment =
    if config.modules.impermanenceExtra.enabled
    then {
      persistence."${config.modules.impermanenceExtra.defaultPath}" = {
        directories = [
          "/var/lib/fwupd"
        ];
      };
    }
    else {};
}
