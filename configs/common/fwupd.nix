{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.services.fwupd.enable {
  environment =
    lib.mkIf config.modules.impermanenceExtra.enabled
    {
      persistence."${config.modules.impermanenceExtra.defaultPath}" = {
        directories = [
          "/var/lib/fwupd"
        ];
      };
    };
}
