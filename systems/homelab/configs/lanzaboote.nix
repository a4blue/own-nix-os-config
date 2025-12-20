{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/sbctl";
        user = "root";
        group = "root";
      }
    ];
  };
}
