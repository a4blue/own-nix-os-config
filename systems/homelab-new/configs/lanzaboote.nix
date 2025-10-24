{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/sbctl";
        user = "root";
        group = "root";
      }
    ];
  };
}
