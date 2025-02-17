{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.alacritty;
in {
  options.modules.alacritty.enable = lib.mkEnableOption "Enable Alacritty";
}
