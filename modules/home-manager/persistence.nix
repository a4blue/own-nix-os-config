{
  lib,
  config,
  ...
}:
lib.mkIf (config.home
  ? persistence) {
  home.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      ".ssh"
      "nixos-git"
      ".local/share/containers"
    ];
  };
}
