{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.zellij.enable {
  programs.zellij = {
    settings = {
      theme = "everforest-dark";
      default_mode = "locked";
    };
  };
}
