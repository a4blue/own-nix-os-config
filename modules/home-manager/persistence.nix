{
  lib,
  config,
  ...
}:
lib.mkIf (config.home
  ? persistence) {
  home.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    allowOther = true;
    directories = [
      ".ssh"
      "nixos-git"
    ];
  };
}
