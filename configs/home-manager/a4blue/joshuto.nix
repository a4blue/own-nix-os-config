{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.joshuto.enable) {
  programs.joshuto = {
    settings = {};
  };
}
