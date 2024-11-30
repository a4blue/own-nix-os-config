{
  lib,
  config,
  ...
}:
lib.mkIf (config.home
  ? persistence) {
  home.persistence."/persistent/home/a4blue" = {
    allowOther = true;
    directories = [
      ".ssh"
      "nixos-git"
    ];
  };
}
