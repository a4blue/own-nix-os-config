{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.bottom.enable) {
  programs.bottom = {
    settings = {};
  };
}
